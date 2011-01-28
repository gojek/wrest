require "spec_helper"
require "#{Wrest::Root}/wrest/native"
require "#{Wrest::Root}/wrest/multipart"

module Wrest
  describe Native::PostMultipart do
    context "functional", :functional => true do

      before :all do
        Wrest.use_native!
      end

      it "should know how to post files using multipart" do
        response = nil
        File.open(File.expand_path(__FILE__)) do |file|
          response = 'http://localhost:3000/uploads'.to_uri.post_multipart({'file' => UploadIO.new(file, "text/plain", File.expand_path(__FILE__))}, 'Whacky-Headers' => 'Foo-Stuff').deserialise
        end

        File.open(File.expand_path(__FILE__)) { |file| response['file'].should == file.readlines.join }

        response['headers'].should include('whacky_headers' => 'Foo-Stuff')
      end

      it "should know how to put files using multipart" do
        response = nil
        File.open(File.expand_path(__FILE__)) do |file|
          response = 'http://localhost:3000/uploads/1'.to_uri.put_multipart('file' => UploadIO.new(file, "text/plain", File.expand_path(__FILE__)))
        end
        File.open(File.expand_path(__FILE__)) { |file| response.body.should == file.readlines.join }
      end
    end
  end
end
