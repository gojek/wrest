require 'wrest/xml_mini/nokogiri/xpath_filter'
module ActiveSupport
  module XmlMini_Nokogiri 
    XmlMini_Nokogiri.extend(::XmlMini::Nokogiri::XPathFilter)
  end
end

