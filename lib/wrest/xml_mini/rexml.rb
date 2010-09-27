require 'wrest/xml_mini/rexml/xpath_filter'
module ActiveSupport
  module XmlMini_REXML 
    XmlMini_REXML.extend(Xml_Mini::Rexml::XPathFilter)
  end
end

    
