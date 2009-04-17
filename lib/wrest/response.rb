# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest #:nodoc:
  # Decorates a response providing support for deserialisation. 
  #
  # The following methods are also available (unlisted by rdoc because they're forwarded):
  #
  # <tt>:@http_response,  :code, :message, :body, :http_version, 
  # :[], :content_length, :content_type, :each_header, :each_name, :each_value, :fetch,
  # :get_fields, :key?, :type_params</tt>
  #
  # They behave exactly like their Net::HTTPResponse equivalents.
  class Response
    extend Forwardable
    def_delegators  :@http_response,  :code, :message, :body, :http_version, 
                    :[], :content_length, :content_type, :each_header, :each_name, :each_value, :fetch,
                    :get_fields, :key?, :type_params
    
    def initialize(http_response)
      @http_response = http_response
    end
    
    def deserialise
      deserialise_using(Wrest::Translators.load(@http_response.content_type))
    end
    
    def deserialise_using(translator)
      translator.call(@http_response)
    end
  end
end