require File.dirname(__FILE__) + '/../../spec_helper'

describe String, 'extensions' do
  it "should know how to convert a string to a Wrest::Uri" do
    'http://localhost:3000'.to_uri.should == Wrest::Uri.new('http://localhost:3000')
  end
end
