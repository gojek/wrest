module XmlMini
  module Rexml
    module XPathFilter
      # Enables filtering of an xml response using a specified xpath
      # Returns an array of elements matching the xpath
      def filter(xml_body, xpath)
        doc = REXML::Document.new(xml_body)
        REXML::XPath.each(doc, xpath).to_a
      end
    end
  end
end
