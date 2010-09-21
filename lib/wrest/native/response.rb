# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at Http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 
require "rexml/document"
module Wrest #:nodoc:
  module Native #:nodoc:
    # Decorates a response providing support for deserialisation.
    #
    # The following methods are also available (unlisted by rdoc because they're forwarded to Net::HTTP::Response):
    #
    # <tt>:@Http_response,  :code, :message, :body, :Http_version,
    # :[], :content_length, :content_type, :each_header, :each_name, :each_value, :fetch,
    # :get_fields, :key?, :type_params</tt>
    #
    # They behave exactly like their Net::HttpResponse equivalents.
    class Response
      attr_reader :http_response
      
      extend Forwardable
      def_delegators  :@http_response,  :code, :message, :body, :Http_version,
              :[], :content_length, :content_type, :each_header, :each_name, :each_value, :fetch,
              :get_fields, :key?, :type_params

      # We're overriding :new to act as a factory so 
      # we can build the appropriate Response instance based
      # on th response code.
      def self.new(http_response)
        code = http_response.code.to_i
        instance = ((300..303).include?(code) || (305..399).include?(code)  ? Wrest::Native::Redirection : self).allocate
        instance.send :initialize, http_response
        instance
      end
              
      def initialize(http_response)
        @http_response = http_response
      end


      def deserialise(options = {})
        deserialise_using(Wrest::Components::Translators.lookup(@http_response.content_type),options)
      end

      def deserialise_using(translator,options = {})
        translator.deserialise(@http_response,options)
      end

      def headers
        @http_response.to_hash
      end
      
      # A null object implementation - invoking this method on
      # a response simply returns the same response unless
      # the response is Redirection (code 3xx), in which case a 
      # get is invoked on the url stored in the response headers
      # under the key 'location' and the new Response is returned.
      def follow(redirect_request_options = {})
        self
      end

      def connection_closed?
        self[Native::StandardHeaders::Connection].downcase == Native::StandardTokens::Close.downcase
      end

      def cacheable?
        code_cacheable? && no_cache_flag_not_set? && no_store_flag_not_set? && expires_header_not_in_past?
      end

      def code_cacheable?
        !code.nil? && !/2\d{2}/.match(code).nil?
      end

      def no_cache_flag_not_set?
        not cache_control_headers.include?('no-cache')
      end

      def no_store_flag_not_set?
        not cache_control_headers.include?('no-store')
      end

      def expires_header_not_in_past?
        expires_header = cache_control_headers.find{ |h| h.include? 'Expires' }
        if expires_header.nil?
          true
        else
          expires_on = DateTime.parse(expires_header.split("=")[1])
          expires_on > DateTime.now
        end
      end

      def cache_control_headers
        @cache_control_headers unless @cache_control_headers.nil?
        if headers['Cache-Control'].nil? then
          @cache_control_headers = []
        else 
          cache_headers = headers['Cache-Control'].split(",")
          @cache_control_headers = correct_expires_headers(cache_headers)
          @cache_control_headers.collect
        end
      end

      :private

      def correct_expires_headers(cache_headers)
        # The expires header "Expires = Sun, 06 Nov 1994 08:49:37 GMT" would have split into two ['Expires = Sun',' 06 Nov 1994 08:49:37 GMT']
        expires_index = cache_headers.find_index(){ |a| a.include? 'Expires' }
        if expires_index
          expires_part_1 = cache_headers.delete(cache_headers[expires_index])
          # earlier delete shifted the second part on same index
          expires_part_2 = cache_headers.delete(cache_headers[expires_index])
          cache_headers.push(expires_part_1+','+expires_part_2)
        end
        cache_headers
      end
    end
  end
end
