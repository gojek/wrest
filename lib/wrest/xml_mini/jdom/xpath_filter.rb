raise "JRuby is required to use the JDOM backend for XmlMini" unless RUBY_PLATFORM =~ /java/




module XmlMini
  module JDOM 
      module XPathFilter
        #Enables filtering of an xml response using a specified xpath
        #Returns an array of elements matching the xpath
        def filter(xml_body,xpath)
          raise NotImplementedError, "'filter' method is not implemented if JDOM backend is being used"
        end

    end
  end
 end
