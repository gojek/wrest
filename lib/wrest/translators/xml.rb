require 'xmlsimple'

module Wrest
  module Translators
    class Xml
      def mime_type
        'application/xml'
      end
      
      def initialize(response)
        @response = response
      end
      
      def deserialise
        XmlSimple.xml_in(
          @response.body,
          'keeproot'  => true
        )
      end
    end
  end
end
    