require 'json'

module Wrest
  module Translators
    class Json
      def mime_type
        'text/javascript'
      end
      
      def initialize(response)
        @response = response
      end
      
      def deserialise
        JSON.parse(@response.body)
      end
    end
  end
end
    