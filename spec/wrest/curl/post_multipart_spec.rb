require "spec_helper"
require "#{Wrest::Root}/wrest/curl"
require "#{Wrest::Root}/wrest/multipart"

module Wrest
  describe Curl::PostMultipart do
    context "functional", :functional => true do

      before :all do
        Wrest.use_curl
      end

      it "should know how to post files using multipart" do
        response = nil
        File.open(File.expand_path(__FILE__)) do |file|
          response = 'http://localhost:3000/uploads'.to_uri.post_multipart({:data => {:test_data => "adfds"}, :file => {:file => File.expand_path(__FILE__)}})
        end
        File.open(File.expand_path(__FILE__)) { |file| response.body.should == file.readlines.join }
      end
    end
  end
end
