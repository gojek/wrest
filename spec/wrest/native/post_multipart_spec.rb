# frozen_string_literal: true

require 'spec_helper'
require 'wrest/native'
require 'wrest/multipart'

module Wrest
  describe Native::PostMultipart do
    context 'functional', functional: true do
      before :all do
        Wrest.use_native!
      end

      it 'knows how to post files using multipart' do
        response = nil
        File.open(File.expand_path(__FILE__)) do |file|
          response = 'http://localhost:3000/uploads'.to_uri.post_multipart(
            { 'file' => UploadIO.new(file, 'text/plain', File.expand_path(__FILE__)) }, 'Whacky-Headers' => 'Foo-Stuff'
          ).deserialise
        end

        File.open(File.expand_path(__FILE__)) { |file| expect(response['file']).to eq(file.readlines.join) }

        expect(response['headers']).to include('whacky_headers' => 'Foo-Stuff')
      end

      it 'knows how to put files using multipart' do
        response = nil
        File.open(File.expand_path(__FILE__)) do |file|
          response = 'http://localhost:3000/uploads/1'.to_uri.put_multipart('file' => UploadIO.new(file, 'text/plain',
                                                                                                   File.expand_path(__FILE__)))
        end
        File.open(File.expand_path(__FILE__)) { |file| expect(response.body).to eq(file.readlines.join) }
      end
    end
  end
end
