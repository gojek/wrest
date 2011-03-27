require "spec_helper"


unless RUBY_PLATFORM =~ /java/
  module Wrest
    describe Curl::Request do
      before :all do
        Wrest.use_curl!
      end

      after(:all) do
        Wrest.use_native!
      end

      it "should raise an exception if an options is invoked" do
        lambda{ 'http://localhost:3000/bottles'.to_uri.options }.should raise_error(Wrest::Exceptions::UnsupportedHttpVerb)
      end

      context "functional", :functional => true do

        it "should have a empty string for a body" do
          Wrest::Curl::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, :get).invoke.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<lead-bottle>\n  <id type=\"integer\">1</id>\n  <name>Wooz</name>\n  <universe-id type=\"integer\" nil=\"true\"></universe-id>\n</lead-bottle>\n"
        end

        it "should raise a Wrest exception on timeout", :functional => true do
          lambda{ 
            Wrest::Curl::Request.new('http://localhost:3000/two_seconds'.to_uri, :get, {}, '', {}, :timeout => 1).invoke 
          }.should raise_error(Wrest::Exceptions::Timeout)
        end
      end

      after :all do
        Wrest.use_native!
      end
    end
  end
end
