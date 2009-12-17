require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Native::Request do
    it "should have a empty string for a body" do
      Wrest::Native::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, Net::HTTP::Get).invoke.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<lead-bottle>\n  <id type=\"integer\">1</id>\n  <name>Wooz</name>\n  <universe-id type=\"integer\" nil=\"true\"></universe-id>\n</lead-bottle>\n"
    end
    
    it "should raise a Wrest exception on timeout" do
      lambda{ 
        Wrest::Native::Request.new('http://localhost:3000/two_seconds'.to_uri, Net::HTTP::Get, {}, '', {}, :timeout => 1).invoke 
        }.should raise_error(Wrest::Exceptions::Timeout)
    end
  end
end