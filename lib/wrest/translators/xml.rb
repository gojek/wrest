require 'xmlsimple'

module Wrest
  module Translators
    Xml = lambda{|response|
        XmlSimple.xml_in(
          response.body,
          'keeproot'  => true
        )
    }
  end
end
    