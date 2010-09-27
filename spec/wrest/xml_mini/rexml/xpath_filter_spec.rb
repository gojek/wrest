require "spec_helper"
require 'wrest/xml_mini/rexml/xpath_filter'
module Xml_Mini
  module Rexml
    describe XPathFilter do
      before :each do
        @testObj = Object.new
        @testObj.extend(XPathFilter)
      end

      it "should filter using the given xpath and return the first matching node found" do
        @testObj.filter("<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>",'//Name').should == "<Name><FirstName>ooga</FirstName></Name>" 
      end
    end
  end
end
#
