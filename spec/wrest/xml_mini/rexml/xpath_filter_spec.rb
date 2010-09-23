require "spec_helper"
require 'wrest/xml_mini/rexml/xpath_filter'

describe REXML_Filter do
  #include REXML_Filter
  before :each do
    @testObj = Object.new
    @testObj.extend(REXML_Filter)
  end

  it "should filter using the given xpath and return the first matching node found" do
    http_response = mock('Http Response')
    http_response.should_receive(:body).and_return("<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>")

    @testObj.filter(http_response,'//Name').should == "<Name><FirstName>ooga</FirstName></Name>" 
  end
end
