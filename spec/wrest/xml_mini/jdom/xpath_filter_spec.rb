if RUBY_PLATFORM =~ /java/
  require "spec_helper"
  require 'wrest/xml_mini/jdom/xpath_filter'
  module XmlMini
    module JDOM
      describe XPathFilter do
        before :each do
          @testObj = Object.new
          @testObj.extend(XPathFilter)
        end

        it "should throw a not implented exception when filter command is invoked and ActiveSupport_XmlMini backend is JDOM" do
          lambda{ @testObj.filter("<xmlbody/>","xpath")}.should raise_error(NotImplementedError)
        end
      end
    end
  end
end

