# frozen_string_literal: true

require 'spec_helper'

module ActiveSupport
  describe XmlMini_REXML, 'filter' do
    it 'filters using the given xpath and return the first matching node found' do
      res_arr = described_class.filter(
        '<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>', '//Name'
      )
      result = ''
      res_arr.each { |e| result += e.to_s }
      result.should == '<Name><FirstName>ooga</FirstName></Name><Name>Bangalore</Name>'
    end
  end
end
