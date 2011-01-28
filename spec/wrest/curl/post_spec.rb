require "spec_helper"

unless RUBY_PLATFORM =~ /java/
  require "#{Wrest::Root}/wrest/curl"

  module Wrest
    describe Curl::Post do
      context "functional", :functional => true do

        before :all do
          Wrest.use_curl!
        end

        it "should know how to post" do
          response = 'http://localhost:3000/nothing'.to_uri.post
          response.body.should == " " 
        end
      end
    end
  end
end