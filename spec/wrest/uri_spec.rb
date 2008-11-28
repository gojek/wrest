require File.dirname(__FILE__) + '/../spec_helper'

describe Wrest::Uri do  
  it "should respond to the four http actions" do
    uri = Wrest::Uri
    uri.should respond_to(:get)
    uri.should respond_to(:post)
    uri.should respond_to(:put)
    uri.should respond_to(:delete)
  end
end