require "spec_helper"

module Wrest
  describe Native::Response do
    it "should build a Redirection instead of a normal response if the code is 301..303 or 305..3xx" do
      http_response = mock(Net::HTTPRedirection)
      http_response.stub!(:code).and_return('301')
      
      Native::Response.new(http_response).class.should == Wrest::Native::Redirection
    end

    it "should build a normal response if the code is 304" do
      http_response = mock(Net::HTTPRedirection)
      http_response.stub!(:code).and_return('304')
      
      Native::Response.new(http_response).class.should == Wrest::Native::Response
    end
    
    it "should build a normal Response for non 3xx codes" do
      http_response = mock(Net::HTTPResponse)
      http_response.stub!(:code).and_return('200')
      
      Native::Response.new(http_response).class.should == Wrest::Native::Response
    end
    
    it "should know how to delegate to a translator" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('200')
      Components::Translators::Xml.should_receive(:deserialise).with(http_response,{})
      Native::Response.new(http_response).deserialise_using(Components::Translators::Xml)
    end

    it "should know how to load a translator based on content type" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('422')
      http_response.should_receive(:content_type).and_return('application/xml')

      response = Native::Response.new(http_response)
      response.should_receive(:deserialise_using).with(Components::Translators::Xml,{})

      response.deserialise
    end

    it "should know how to deserialise a json response" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('200')
      http_response.should_receive(:body).and_return("{ \"menu\": \"File\",
      \"commands\": [ { \"title\": \"New\", \"action\":\"CreateDoc\" }, {
      \"title\": \"Open\", \"action\": \"OpenDoc\" }, { \"title\": \"Close\",
      \"action\": \"CloseDoc\" } ] }")
      http_response.should_receive(:content_type).and_return('application/json')

      response = Native::Response.new(http_response)
      
      response.deserialise.should == { "commands"=>[{"title"=>"New",
        "action"=>"CreateDoc"},
        {"title"=>"Open","action"=>"OpenDoc"},{"title"=>"Close",
          "action"=>"CloseDoc"}], "menu"=>"File"}
      
    end

    it "should simply return itself when asked to follow (null object behaviour - see MovedPermanently for more context)" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('422')
      
      response = Native::Response.new(http_response)
      response.follow.equal?(response).should be_true
    end
    
    describe 'Keep-Alive' do
      it "should know when a connection has been closed" do
        http_response = build_ok_response
        http_response.should_receive(:[]).with(Wrest::H::Connection).and_return('Close')
    
        response = Native::Response.new(http_response)
        response.should be_connection_closed
      end
      
      it "should know when a keep-alive connection has been estalished" do
        http_response = build_ok_response
        http_response.should_receive(:[]).with(Wrest::H::Connection).and_return('')
    
        response = Native::Response.new(http_response)
        response.should_not be_connection_closed
      end
    end

    describe 'caching' do
      describe "cases where response should be cached" do
        it "should say its cacheable if the response code is cacheable" do
          # the cacheable codes are enumerated in Firefox source code: nsHttpResponseHead.cpp::MustValidate
          http_response = build_ok_response('', cacheable_headers)
          ['200', '203', '300', '301'].each do |code|
            http_response.stub!(:code).and_return(code)
            response = Native::Response.new(http_response)
            response.cacheable?.should == true
          end
        end


        it "should be cacheable for response with Expires header in future" do
          ten_mins_after = (Time.now + (10*30)).httpdate
          response = Native::Response.new(build_ok_response('', cacheable_headers))
          response.cacheable?.should == true
        end

        it "should be cacheable for response with max-age still not expired" do
          response = Native::Response.new(build_ok_response('', cacheable_headers.merge('Cache-Control' => "max-age=#{10*30}".tap {|h| h.delete("Expires")}))) # 30mins max-age
          response.cacheable?.should == true
        end
      end

      describe "cases where response should not be cached" do
        it "should say its not cacheable if the response code is not range of 200-299" do
          http_response = build_ok_response('', cacheable_headers)
          ['100', '206', '400', '401', '500'].each do |code|
            http_response.stub!(:code).and_return(code)
            response = Native::Response.new(http_response)
            response.cacheable?.should == false
          end
        end

        it "should not be cacheable for responses with neither Expires nor Max-Age" do
          response = Native::Response.new(build_ok_response)
          response.cacheable?.should == false
        end

        it "should not be cacheable for responses with invalid Expires or Date values" do
          response = Native::Response.new(build_ok_response('', cacheable_headers.merge("Expires" => "invalid date")))
          response.cacheable?.should == false

          response = Native::Response.new(build_ok_response('', cacheable_headers.merge("Date" => "invalid date")))
          response.cacheable?.should == false
        end

        it "should not be cacheable for responses with cache-control header no-cache" do
          response = Native::Response.new(build_ok_response('', 'Cache-Control' => 'no-cache'))
          response.cacheable?.should == false
        end

        it "should not be cacheable for responses with cache-control header no-store" do
          response = Native::Response.new(build_ok_response('', 'Cache-Control' => 'no-store'))
          response.cacheable?.should == false
        end

        it "should not be cacheable for responses with header pragma no-cache" do
          response = Native::Response.new(build_ok_response('', cacheable_headers.merge('Pragma' => 'no-cache')))    # HTTP 1.0
          response.cacheable?.should == false
        end

        it "should not be cacheable for response with Expires header in past" do
          ten_mins_early = (Time.now - (10*30)).httpdate

          response = Native::Response.new(build_ok_response('', cacheable_headers.merge("Expires" => ten_mins_early)))
          response.cacheable?.should == false
        end

        it "should not be cacheable for response without a max-age, and its Expires is already less than its Date" do
          one_day_before = (Time.now - (24*60*60)).httpdate
          response = Native::Response.new(build_ok_response('', cacheable_headers.merge("Expires" => one_day_before)))
          response.cacheable?.should == false
        end

        it "should not be cacheable for response with a vary tag" do
          response = Native::Response.new(build_ok_response('', cacheable_headers.merge('Vary' => 'something')))
          response.cacheable?.should == false
        end
      end

      describe "page validity and expiry" do
        before :each do
          current_time    =Time.now

          ten_mins_early  = (current_time - (10*60)).httpdate
          half_hour_after = (current_time + (30*60)).httpdate

          # All responses in the caching block returns a cacheable response by default
          @headers        = {
              "Date"          => ten_mins_early,
              "Expires"       => half_hour_after,
              "Age"           => 5*60,
              "Last-Modified" => ten_mins_early
          }
        end


        it "should return correct values for current_age" do
          response = Native::Response.new(build_ok_response('', @headers))
          (response.current_age - (10*60)).abs.to_i.should == 0 # current_age should be 600, but it is temporal - so the rounding off.

          @headers["Age"] = 100*60 # 100 minutes - Age is larger than Now-Expires
          response        = Native::Response.new(build_ok_response('', @headers))
          (response.current_age - (100*60)).abs.to_i.should == 0
        end

        it "should return correct values for freshness_lifetime" do
          response = Native::Response.new(build_ok_response('', @headers))
          response.freshness_lifetime.should == (40*60)

          @headers["Cache-Control"] = "max-age=600"
          response                  = Native::Response.new(build_ok_response('', @headers))
          response.freshness_lifetime.should == 600 # max-age takes priority over Expires
        end

        it "should say not expired for requests with Expires in the future" do
          response = Native::Response.new(build_ok_response('', @headers))
          response.expired?.should == false
        end

        it "should say expired for requests with Expires in the past" do
          time_in_past        =(Time.now - (10*60)).httpdate
          @headers["Expires"] = time_in_past
          response            = Native::Response.new(build_ok_response('', @headers))
          response.expired?.should == true
        end

        it "should say expired for requests that have lived past its max-age" do
          @headers.delete "Expires"
          @headers["Cache-Control"] = "max-age=0"
          response                  = Native::Response.new(build_ok_response('', @headers))
          response.expired?.should == true
        end

        it "should say not expired for requests that haven't reached max-age" do
          @headers["Cache-Control"] = "max-age=60000"
          response                  = Native::Response.new(build_ok_response('', @headers))
          response.expired?.should == false
        end

      end
    end

    context "functional", :functional => true do
      before :each do
        @response = Wrest::Native::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, Net::HTTP::Get).invoke
      end

      it "should be a Http::Response" do
        @response.class.should == Native::Response
      end

      it "should provide access to its headers in a case-insensitive manner via []" do
        @response.headers['content-type'].should == ['application/xml; charset=utf-8']
        @response.headers['Content-Type'].should be_nil

        @response['Content-Type'].should == 'application/xml; charset=utf-8'
        @response['content-type'].should == 'application/xml; charset=utf-8'
      end
    end
  end
end