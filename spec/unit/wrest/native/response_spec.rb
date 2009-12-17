require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Native::Response do
    it "should build a Redirection instead of a normal response if the code is 301..303 or 305..3xx" do
      http_response = mock(Net::HTTPRedirection)
      http_response.stub!(:code).and_return('301')
      
      Native::Response.new(http_response).class.should == Wrest::Native::Redirection
    end

    it "should build a normal response if the code is 304" do
      http_response = mock(Net::HTTPRedirection)
      http_response.stub!(:code).and_return('304')
      
      Native::Response.new(http_response).class.should == Wrest::Native::Response
    end
    
    it "should build a normal Response for non 3xx codes" do
      http_response = mock(Net::HTTPResponse)
      http_response.stub!(:code).and_return('200')
      
      Native::Response.new(http_response).class.should == Wrest::Native::Response
    end
    
    it "should know how to delegate to a translator" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('200')
      Components::Translators::Xml.should_receive(:deserialise).with(http_response)
      Native::Response.new(http_response).deserialise_using(Components::Translators::Xml)
    end

    it "should know how to load a translator based on content type" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('422')
      http_response.should_receive(:content_type).and_return('application/xml')

      response = Native::Response.new(http_response)
      response.should_receive(:deserialise_using).with(Components::Translators::Xml)

      response.deserialise
    end
    
    it "should simply return itself when asked to follow (null object behaviour - see MovedPermanently for more context)" do
      http_response = mock('response')
      http_response.stub!(:code).and_return('422')
      
      response = Native::Response.new(http_response)
      response.follow.equal?(response).should be_true
    end
    
    describe 'Keep-Alive' do
      it "should know when a connection has been closed" do
        http_response = mock('response')
        http_response.stub!(:code).and_return('200')
        http_response.should_receive(:[]).with(Wrest::H::Connection).and_return('Close')
    
        response = Native::Response.new(http_response)
        response.should be_connection_closed
      end
      
      it "should know when a keep-alive connection has been estalished" do
        http_response = mock('response')
        http_response.stub!(:code).and_return('200')
        http_response.should_receive(:[]).with(Wrest::H::Connection).and_return('')
    
        response = Native::Response.new(http_response)
        response.should_not be_connection_closed
      end
    end
  end
end
