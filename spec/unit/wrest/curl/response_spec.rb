require File.dirname(__FILE__) + '/../../spec_helper'

unless RUBY_PLATFORM =~ /java/
  module Wrest
    describe Curl::Response do
      describe 'Headers' do
        it "should know how to retrieve content type irrespective of the casing" do
          http_response = mock('Patron::Response')
          http_response.stub!(:headers).and_return({'Content-type' => 'text/xml;charset=utf-8'})
          response = Wrest::Curl::Response.new(http_response)
          response.content_type.should == 'text/xml'
        end
      end
    end
  end
end
