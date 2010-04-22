require File.dirname(__FILE__) + '/../../spec_helper'
require "#{Wrest::Root}/wrest/native"
require "#{Wrest::Root}/wrest/multipart"
Wrest::Http = Wrest::Native

module Wrest
  describe Native::PostMultipart do
    it "should know how to post files using multipart" do
      response = nil
      File.open(File.expand_path(__FILE__)) do |file|
        response = 'http://localhost:3000/uploads'.to_uri.post_multipart('file' => UploadIO.new(file, "text/plain", File.expand_path(__FILE__)))
      end
      File.open(File.expand_path(__FILE__)) { |file| response.body.should == file.readlines.join }
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