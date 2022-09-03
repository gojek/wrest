# frozen_string_literal: true
require 'spec_helper'
require 'wrest/xml_mini/rexml/xpath_filter'
module XmlMini
  module Rexml
    describe XPathFilter do
      before do
        @testObj = Object.new
        @testObj.extend(XPathFilter)
      end

      it 'filters using the given xpath and return an array of matching nodes found' do
        res_arr = @testObj.filter(
          '<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>', '//Name'
        )
        result = ''
        res_arr.each { |e| result += e.to_s }
        result.should == '<Name><FirstName>ooga</FirstName></Name><Name>Bangalore</Name>'
      end
    end
  end
end
