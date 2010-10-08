require 'wrest/xml_mini/libxml/xpath_filter'
module ActiveSupport
  module XmlMini_LibXML
    XmlMini_LibXML.extend(::XmlMini::LibXML::XPathFilter)
  end
end


