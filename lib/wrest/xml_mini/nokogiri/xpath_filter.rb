module XmlMini
  module Nokogiri
    module XPathFilter
      #Enables filtering of an xml response using a specified xpath
      #Returns all elements that match the xpath
      def filter(xml_body,xpath)
        doc = ::Nokogiri::XML(xml_body)
        doc.xpath(xpath).to_a 
      end
    end
  end
end



