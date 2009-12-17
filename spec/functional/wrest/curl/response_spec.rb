require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Curl::Response do
    before :all do
      @response = Wrest::Curl::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, :get).invoke
    end

    it "should be a Curl::Response" do
      @response.class.should == Curl::Response
    end

    it "should contain a Patron::Response" do
      @response.http_response.class.should == Patron::Response
    end

    it "should know its code" do
      @response.code.should == 200
    end
    
    it "should provide access to its headers in a case-insensitive manner via []" do
      @response.headers['Content-Type'].should == 'application/xml; charset=utf-8'
      @response.headers['content-type'].should == "application/xml; charset=utf-8"
    
      @response['Content-Type'].should == 'application/xml; charset=utf-8'
      @response['content-type'].should == 'application/xml; charset=utf-8'
    end

    it "should provide access to the content-length" do
      @response.headers['Content-Length'].should == '172'
      @response.content_length.should == 172
    end
  end
end
