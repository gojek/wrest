module XmlMini
  module LibXML
    module XPathFilter
      #Enables filtering of an xml response using a specified xpath
      #Returns an array of elements matching the xpath
      def filter(xml_body,xpath)
        doc = ::LibXML::XML::Document.string(xml_body)
        doc.find(xpath).to_a
      end
    end
  end
end
