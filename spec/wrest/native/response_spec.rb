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
      it "should say its cacheable if the response code is in range of 200-299" do
        http_response = build_ok_response
        ['200','210','299'].each do |code|
          http_response.stub!(:code).and_return(code)
          response = Native::Response.new(http_response)
          response.cacheable?.should == true
        end
      end

      it "should say its not cacheable if the response code is not range of 200-299" do
        http_response = build_ok_response
        ['100','300','400','500'].each do |code|
          http_response.stub!(:code).and_return(code)
          response = Native::Response.new(http_response)
          response.cacheable?.should == false
        end
      end

      describe 'with HTTP/1.1 protocol' do
        it "should not be cacheable for responses with cache-control header no-cache" do
          response = Native::Response.new(build_ok_response('','Cache-Control' => 'no-cache'))
          response.cacheable?.should == false
        end

        it "should not be cacheable for responses with cache-control header no-store" do
          response = Native::Response.new(build_ok_response('','Cache-Control' => 'no-store'))
          response.cacheable?.should == false
        end

        it "should not be cacheable for response with Expires header in past" do
          yesterday_in_rfc822_format = format_date_in_rfc822_format(DateTime.now - 1)
          response = Native::Response.new(build_ok_response('','Cache-Control' => 'Expires = '+yesterday_in_rfc822_format))
          response.cacheable?.should == false
        end

        it "should be cacheable for response with Expires header in future" do
          yesterday_in_rfc822_format = format_date_in_rfc822_format(DateTime.now + 1)
          response = Native::Response.new(build_ok_response('','Cache-Control' => 'Expires = '+yesterday_in_rfc822_format))
          response.cacheable?.should == true
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
