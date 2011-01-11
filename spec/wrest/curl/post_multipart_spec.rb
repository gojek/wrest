require "spec_helper"
require "#{Wrest::Root}/wrest/curl"
require "#{Wrest::Root}/wrest/multipart"

module Wrest
  describe Curl::PostMultipart do
    context "functional", :functional => true do

      before :all do
        Wrest.use_curl
      end

      it "should know how to post files using multipart with net:http like api" do
        response = nil
        File.open(File.expand_path(__FILE__)) do |file|
          response = 'http://localhost:3000/uploads'.to_uri.post_multipart('file' => UploadIO.new(file, "text/plain", File.expand_path(__FILE__)))
        end
        File.open(File.expand_path(__FILE__)) { |file| response.body.should == file.readlines.join }
      end

       it "should how to post files using multipart with curl api" do
         response = nil
         File.open(File.expand_path(__FILE__)) do |file|
           response = 'http://localhost:3000/uploads'.to_uri.post_multipart({:data => "adfds", :file => File.expand_path(__FILE__)})
         end
         File.open(File.expand_path(__FILE__)) { |file| response.body.should == file.readlines.join }
       end
    end
  end
end
