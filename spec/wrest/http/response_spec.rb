# frozen_string_literal: true
require 'spec_helper'

module Wrest
  libraries = [Wrest::Native]

  libraries.each do |library|
    describe "For #{library}" do
      describe 'Response' do
        describe 'Headers' do
          it 'knows how to retrieve content type irrespective of the casing' do
            http_response = double('Response')
            allow(http_response).to receive(:headers).and_return({ 'Content-type' => 'application/xml' })
            allow(http_response).to receive(:code).and_return('200')
            allow(http_response).to receive(:content_type).and_return('application/xml')

            response = library::Response.new(http_response)
            response.content_type.should == 'application/xml'
          end
        end
      end
    end
  end
end
