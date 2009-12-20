require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  libraries = [Wrest::Native]
  libraries << Wrest::Curl unless RUBY_PLATFORM =~ /java/
    
  libraries.each do |library|
    describe "For #{library}" do
      describe 'Response' do
        describe 'Headers' do
          it "should know how to retrieve content type irrespective of the casing" do
            http_response = mock('Response')
            http_response.stub!(:headers).and_return({'Content-type' => 'application/xml'})
            http_response.stub!(:code).and_return('200')
            http_response.stub!(:content_type).and_return('application/xml')
            
            response = library::Response.new(http_response)
            response.content_type.should == 'application/xml'
          end
        end
      end
    end
  end
end
