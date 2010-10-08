require 'wrest/xml_mini/jdom/xpath_filter'
module ActiveSupport
  module XmlMini_JDOM
    XmlMini_JDOM.extend(::XmlMini::JDOM::XPathFilter)
  end
end
