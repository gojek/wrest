unless (RUBY_PLATFORM =~ /java/ || (Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/))
  require "spec_helper"
  require 'wrest/xml_mini/libxml/xpath_filter'
  require 'libxml'
  module XmlMini
    module LibXML
      describe XPathFilter do
        before :each do
          @testObj = Object.new
          @testObj.extend(XPathFilter)
        end

        it "should filter using the given xpath and return an array of matching nodes found" do
          res_arr = @testObj.filter("<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>",'//Name')
          result = ""
          res_arr.each { |e| result+=e.to_s.gsub(/[\n]+/, "").gsub(' ','')}
          result.should == "<Name><FirstName>ooga</FirstName></Name><Name>Bangalore</Name>"
        end
      end
    end
  end
end

