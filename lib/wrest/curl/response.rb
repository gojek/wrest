# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at Http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest #:nodoc:
  module Curl #:nodoc:
    # Decorates a response providing support for deserialisation.
    #
    # Also provides set of HTTP response code checkers. For instance, the method ok? checks if the response was
    # successful with HTTP code 200.
    # See HttpCodes for a list of all such response checkers.
    class Response              
      attr_reader :http_response
      attr_accessor :deserialised_body
      include HttpShared::Headers
      include HttpCodes
      
      extend Forwardable
      def_delegators  :@http_response, :body, :headers
      
      def initialize_http_header
        headers.merge!(headers.inject({}) do |downcased_headers, tuple|
          key, value = tuple
          downcased_headers[key.downcase] = value
          downcased_headers
        end)
      end
      
      def initialize(http_response)
        @http_response = http_response
        initialize_http_header
      end

      def deserialise(options = {})
          @deserialised_body ||= deserialise_using(Wrest::Components::Translators.lookup(content_type),options)
      end

      def deserialise_using(translator,options={})
        translator.deserialise(@http_response,options)
      end
      
      def code
        @http_response.status
      end
      
      def message
        @http_response.status_line
      end
      
      def content_length
        self[H::ContentLength].try(:to_i)
      end
    
      def content_type
        self[H::ContentType].split(';').first
      end
            
      # A null object implementation - invoking this method on
      # a response simply returns the same response unless
      # the response is a Redirection (code 3xx), in which case a 
      # get is invoked on the url stored in the response headers
      # under the key 'location' and the new Response is returned.
      def follow(redirect_request_options = {})
        self
      end
      
      def connection_closed?
        self[StandardHeaders::Connection].downcase == StandardTokens::Close.downcase
      end
    end
  end
end
