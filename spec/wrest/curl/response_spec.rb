require "spec_helper"

unless RUBY_PLATFORM =~ /java/
  module Wrest
    describe Curl::Response do
      describe 'Headers' do
        it "should know how to retrieve content type irrespective of the casing" do
          http_response = mock('Patron::Response')
          http_response.stub!(:headers).and_return({'Content-type' => 'text/xml;charset=utf-8'})
          response = Wrest::Curl::Response.new(http_response)
          response.content_type.should == 'text/xml'
        end
      end

      it "should know how to deserialise json responses" do
        http_response = mock('response')
        http_response.stub!(:code).and_return('200')
        http_response.should_receive(:body).and_return(<<-EOJS
        { 
          "menu": "File",
          "commands": [ 
            { "title": "New", "action":"CreateDoc" }, 
            { "title": "Open", "action": "OpenDoc" }, 
            { "title": "Close", "action": "CloseDoc" } 
          ] 
        }
EOJS
)
        http_response.should_receive(:content_type).and_return('application/json')

        response = Native::Response.new(http_response)
    
        response.deserialise.should == { "commands"=>[{"title"=>"New",
              "action"=>"CreateDoc"},
              {"title"=>"Open","action"=>"OpenDoc"},{"title"=>"Close",
              "action"=>"CloseDoc"}], "menu"=>"File"}
      end
     
      
      describe "cache deserialised body" do
      it "should return the catched deserialised body when deserialise is called more than once" do
        http_response = mock('curl response')
        http_response.stub!(:headers).and_return({'Content-type' => 'text/xml;charset=utf-8'})

        response = Wrest::Curl::Response.new(http_response)

        response.should_receive(:deserialise_using).exactly(1).times.and_return("deserialise")

        response.deserialise
        response.deserialise
      end
    end


      context "functional", :functional => true do
        context 'simple headers' do
          before :all do
            @response = Wrest::Curl::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, :get).invoke
          end

          it "should be a Curl::Response" do
            @response.class.should == Curl::Response
          end

          it "should contain a Patron::Response" do
            @response.http_response.class.should == Patron::Response
          end

          it "should know its code" do
            @response.code.should == 200
          end

          it "should provide access to its headers in a case-insensitive manner via []" do
            @response.headers['Content-Type'].should == 'application/xml; charset=utf-8'
            @response.headers['content-type'].should == "application/xml; charset=utf-8"

            @response['Content-Type'].should == 'application/xml; charset=utf-8'
            @response['content-type'].should == 'application/xml; charset=utf-8'
          end

          it "should provide access to the content-length" do
            @response.headers['Content-Length'].should == '172'
            @response.content_length.should == 172
          end
        end
        
        it "should handle headers with multiple values where the values are made available in an array" do
          response = Wrest::Curl::Request.new('http://localhost:3000/multiple_response_headers'.to_uri, :get).invoke
          response.code.should == 200
          response['Set-Cookie'].should be_an(Array)
        end

      end
    end
  end
end

