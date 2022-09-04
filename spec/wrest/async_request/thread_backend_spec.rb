# frozen_string_literal: true

require 'spec_helper'

module Wrest
  module AsyncRequest
    describe ThreadBackend do
      describe 'executing requests' do
        it 'executes the given request asynchronously using threads' do
          hash = {}
          uri = 'http://localhost:3000'.to_uri
          request = Wrest::Native::Get.new(uri, {}, {}, callback: Wrest::Callback.new({ 200 => lambda { |_response|
                                                                                                 hash['success'] = true
                                                                                               } }))
          response200 = double(Net::HTTPOK, code: '200', message: 'OK', body: '', to_hash: {})
          expect(request).to receive(:do_request).and_return(response200)

          async_obj = described_class.new
          async_obj.execute(request)
          sleep 1
          expect(hash.key?('success')).to be_truthy
        end
      end
    end
  end
end
