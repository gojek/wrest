require "spec_helper"
require "#{Wrest::Root}/wrest/multipart"

unless RUBY_PLATFORM =~ /java/
  require "#{Wrest::Root}/wrest/curl"

  module Wrest
    describe Curl::PutMultipart do
      context "functional" do 

        before :all do
          Wrest.use_curl!
        end

        it "should raise Wrest::Exceptions::UnsupportedFeature error" do
          response = nil
          File.open(File.expand_path(__FILE__)) do |file|
            lambda {
            'http://localhost:3000/uploads'.to_uri.put_multipart('file' => UploadIO.new(file, "text/plain", File.expand_path(__FILE__)))
            }.should raise_error(Wrest::Exceptions::UnsupportedFeature)
          end
        end
      end
    end
  end
end