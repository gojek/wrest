require File.dirname(__FILE__) + '/../spec_helper'

describe Wrest::Base do
  before(:each) do
    @resource = Object.new
    @resource.extend Wrest::Base
  end
  
  it "should ooga" do
    @resource.should respond_to(:get)
    @resource.should respond_to(:post)
    @resource.should respond_to(:put)
    @resource.should respond_to(:delete)
  end
end