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
        @response.body
      end
      
      def serialise(hash)
        Request.new Uri.new()
      end
    end
  end
end
    