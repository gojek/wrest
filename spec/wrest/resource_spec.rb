require File.dirname(__FILE__) + '/../spec_helper'

describe Wrest::Resource do  
  it "should forward get to its uri" do
    uri = 'http://test.host/resource/1'.to_uri
    uri.should_recieve(:get)
    
    Wrest::Resource.new(uri).get
  end
end