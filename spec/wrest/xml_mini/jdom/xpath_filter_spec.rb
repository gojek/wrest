# frozen_string_literal: true

require 'spec_helper'
if RUBY_PLATFORM =~ /java/
  require 'wrest/xml_mini/jdom/xpath_filter'
  module XmlMini
    module JDOM
      describe XPathFilter do
        before do
          @testObj = Object.new
          @testObj.extend(described_class)
        end

        it 'throws a not implented exception when filter command is invoked and ActiveSupport_XmlMini backend is JDOM' do
          expect { @testObj.filter('<xmlbody/>', 'xpath') }.to raise_error(NotImplementedError)
        end
      end
    end
  end
end
