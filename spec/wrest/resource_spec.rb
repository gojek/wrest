require File.dirname(__FILE__) + '/../spec_helper'

describe Wrest::Resource do
  before(:each) do
    @resource = Wrest::Resource.new(nil, nil)
  end
  
  it "should ooga" do
    @resource.should respond_to(:get)
    @resource.should respond_to(:post)
    @resource.should respond_to(:put)
    @resource.should respond_to(:delete)
  end
end