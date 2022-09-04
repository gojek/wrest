# frozen_string_literal: true

if RUBY_PLATFORM =~ /java/
  require 'spec_helper'
  require 'wrest/xml_mini/jdom'
  module ActiveSupport
    describe XmlMini_JDOM, 'filter' do
      before do
        @present_backend = ActiveSupport::XmlMini.backend
        ActiveSupport::XmlMini.backend = 'JDOM'
      end

      after do
        ActiveSupport::XmlMini.backend = @present_backend
      end

      it 'throws a not implented exception when filter command is invoked and ActiveSupport_XmlMini backend is JDOM' do
        expect { described_class.filter('<xmlbody/>', 'xpath') }.to raise_error(NotImplementedError)
      end
    end
  end
end
