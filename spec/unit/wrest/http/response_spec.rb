require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Http::Response do
    it "should build a Redirection instead of a normal response if the code is 3xx" do
      http_response = mock(Net::HTTPRedirection)
      http_response.stub!(:code).and_return('301')
      
      Http::Response.new(http_response).class.should == Wrest::Http::Redirection
    end
    
    it "should build a normal Response for non 3xx codes" do
      http_response = mock(Net::HTTPResponse)
      http_response.stub!(:code).and_return('200')
      
      Http::Response.new(http_response).class.should == Wrest::Http::Response
    end
    
    it "should know how to delegate to a translator" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('200')
      Components::Translators::Xml.should_receive(:deserialise).with(http_response)
      Http::Response.new(http_response).deserialise_using(Components::Translators::Xml)
    end

    it "should know how to load a translator based on content type" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('422')
      http_response.should_receive(:content_type).and_return('application/xml')

      response = Http::Response.new(http_response)
      response.should_receive(:deserialise_using).with(Components::Translators::Xml)

      response.deserialise
    end
    
    it "should simply return itself when asked to follow (null object behaviour - see MovedPermanently for more context)" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('422')
      
      response = Http::Response.new(http_response)
      response.follow.equal?(response).should be_true
    end
  end
end
