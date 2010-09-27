require "spec_helper"

module ActiveSupport 
  describe XmlMini_REXML, 'filter' do
      it "should filter using the given xpath and return the first matching node found" do
      XmlMini_REXML.filter("<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>",'//Name').should == "<Name><FirstName>ooga</FirstName></Name>" 
    end
  end
end
