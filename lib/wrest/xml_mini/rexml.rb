require 'wrest/xml_mini/rexml/xpath_filter'
module ActiveSupport
  module XmlMini_REXML 
    XmlMini_REXML.extend(::XmlMini::Rexml::XPathFilter)
  end
end

    
