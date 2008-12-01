require File.dirname(__FILE__) + '/../spec_helper'
module Wrest
  describe Uri do  
    it "should respond to the four http actions" do
      uri = Uri.new('http://localhost')
      uri.should respond_to(:get)
      uri.should respond_to(:post)
      uri.should respond_to(:put)
      uri.should respond_to(:delete)
    end
  
    it "should know when it is https" do
      Uri.new('https://localhost').should be_https
    end
    
    it "should know when it is not https" do
      Uri.new('http://localhost').should_not be_https
    end
  end
end