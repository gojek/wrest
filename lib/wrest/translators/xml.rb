require 'xmlsimple'

module Wrest 
  module Translators
    # Knows how to deserialise xml.
    # Depends on the xmlsimple gem.
    Xml = lambda{|response|
        XmlSimple.xml_in(
          response.body,
          'keeproot'  => true
        )
    }
  end
end
    