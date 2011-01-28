require "spec_helper"
require "#{Wrest::Root}/wrest/multipart"

unless RUBY_PLATFORM =~ /java/
  require "#{Wrest::Root}/wrest/curl"
  
  module Wrest
    describe Curl::PostMultipart do
      before :all do
        Wrest.use_curl!
      end
      let(:file_path){ File.expand_path(__FILE__) }

      context 'parameter key formats' do
        let(:fake_file){ '/foo/bar.txt' }
        it "should handle strings as parameter keys" do
          request = Wrest::Curl::PostMultipart.new('http://ooga.com'.to_uri, {'file' => fake_file})
          request.file_name.should == {:file => fake_file}
        end
        
        it "should handle symbols as parameter keys" do
          request = Wrest::Curl::PostMultipart.new('http://ooga.com'.to_uri, {:file => fake_file})
          request.file_name.should == {:file => fake_file}
        end
      end
      
      context "options hash handling" do
        it "should not alter the options hash when creating multipart_post request" do
          options = {:username => "asdf", :password => "pass123"}
          saved_options = options.clone
          uri = Uri.new("http://localhost:3000/")
          Wrest::Curl::PostMultipart.new(uri, {'file' => File.expand_path(__FILE__)}, {}, options)
          options.should == saved_options 
        end
      end

      context "functional", :functional => true do

        it "should know how to post files using multipart with net:http like api" do
          response = nil
          File.open(File.expand_path(__FILE__)) do |file|
            response = 'http://localhost:3000/uploads'.to_uri.post_multipart({'file' => file}, 'Whacky-Headers' => 'Foo-Stuff').deserialise
          end
          File.open(File.expand_path(__FILE__)) { |file| response['file'] == file.readlines.join }
          response['headers'].should include('whacky_headers' => 'Foo-Stuff')
        end

        it "should know how to post files using multipart with curl api" do
          response = nil
          File.open(File.expand_path(__FILE__)) do |file|
            response = 'http://localhost:3000/uploads'.to_uri.post_multipart(:data => "adfds", :file => file_path).deserialise
          end
          File.open(File.expand_path(__FILE__)) { |file| response['file'].should == file.readlines.join }
        end
      end
    end
  end
end
