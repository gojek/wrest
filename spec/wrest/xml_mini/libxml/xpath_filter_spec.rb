# frozen_string_literal: true

require 'spec_helper'
if Helpers.xml_backends.include?('LibXML')
  require 'wrest/xml_mini/libxml/xpath_filter'
  require 'libxml'
  module XmlMini
    module LibXML
      describe XPathFilter do
        before do
          @test_obj = Object.new
          @test_obj.extend(described_class)
        end

        it 'filters using the given xpath and return an array of matching nodes found' do
          res_arr = @test_obj.filter(
            '<Person><Personal><Name><FirstName>ooga</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>', '//Name'
          )
          result = ''
          res_arr.each { |e| result += e.to_s.gsub(/\n+/, '').gsub(' ', '') }
          expect(result).to eq('<Name><FirstName>ooga</FirstName></Name><Name>Bangalore</Name>')
        end
      end
    end
  end
end
