require File.dirname(__FILE__) + '/../../spec_helper'
require "#{WREST_ROOT}/wrest/curl"

module Wrest
  describe Http::Response do
    before :each do
      @response = Wrest::Http::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, Net::HTTP::Get).invoke
    end
    
    it "should be a Http::Response" do
      @response.class.should == Http::Response
    end
    
    it "should provide access to its headers in a case-insensitive manner via []" do
      @response.headers['content-type'].should == ['application/xml; charset=utf-8']
      @response.headers['Content-Type'].should be_nil
      
      @response['Content-Type'].should == 'application/xml; charset=utf-8'
      @response['content-type'].should == 'application/xml; charset=utf-8'
    end
  end
end
