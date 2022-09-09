# frozen_string_literal: true

require File.join('active_support', 'xml_mini', 'jdom')
require File.join('wrest', 'xml_mini', 'jdom', 'xpath_filter')

module ActiveSupport
  module XmlMini_JDOM
    XmlMini_JDOM.extend(::XmlMini::JDOM::XPathFilter)
  end
end
