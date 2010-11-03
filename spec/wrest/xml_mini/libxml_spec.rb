unless (RUBY_PLATFORM =~ /java/ || (Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/))
  require "spec_helper"
  require 'wrest/xml_mini/libxml'
  require 'libxml'
  module ActiveSupport 
   describe XmlMini_LibXML, 'filter' do
      it "should filter using the given xpath and return the matching node found as an array" do
        res_arr = XmlMini_LibXML.filter("<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>",'//Name')
        result = ""
        res_arr.each {|e| result+=e.to_s.gsub(/[\n]+/, "").gsub(/\s/, '')}
        result.should == "<Name><FirstName>ooga</FirstName></Name><Name>Bangalore</Name>" 
      end
    end
  end
end

