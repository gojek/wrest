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
      Uri.new('https://localhost:3000').should be_https
    end
    
    it "should know when it is not https" do
      Uri.new('http://localhost:3000').should_not be_https
    end
    
    it "should know how to get" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https
      
      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      http.should_receive(:get).with('/glassware?owner=Kai&type=bottle', 'page' => '2', 'per_page' => '5')
      
      uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
    end
  end
end