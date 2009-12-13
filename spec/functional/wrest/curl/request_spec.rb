require File.dirname(__FILE__) + '/../../spec_helper'
Wrest.use_curl

module Wrest
  describe Curl::Request do
    it "should have a empty string for a body" do
      Wrest::Curl::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, :get).invoke.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<lead-bottle>\n  <id type=\"integer\">1</id>\n  <name>Wooz</name>\n  <universe-id type=\"integer\" nil=\"true\"></universe-id>\n</lead-bottle>\n"
    end
  end
end
