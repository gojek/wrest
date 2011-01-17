# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Native
  class Get < Request
    def initialize(wrest_uri, parameters = {}, headers = {}, options = {})
      follow_redirects = options[:follow_redirects]
      options[:follow_redirects] = (follow_redirects == nil ? true : follow_redirects)
      super(
            wrest_uri, 
            Net::HTTP::Get, 
            parameters,
            nil,
            headers,
            options
          )
    end

    # Checks equality between two Wrest::Native::Get objects.
    # Comparing two Wrest::Native::Get objects with identical values for the following properties would return True.
    #   uri, parameters, username, password and ssh verify_mode.
    def ==(other)
      return true if self.equal?(other)
      return false unless other.class == self.class
      return true if self.uri == other.uri and
        self.parameters == other.parameters and
        self.username == other.username and
        self.password == other.password and
        self.verify_mode == other.verify_mode
    end

    # Returns a hash value for this Wrest::Native::Get object.
    # Objects that returns true when compared using the == operator would return the same hash value also.
    def hash
      self.uri.hash + self.parameters.hash + self.username.hash + self.password.hash + self.verify_mode.hash + 20110106
    end
    
    #:nodoc:
    def invoke_with_cache_check

      return invoke_without_cache_check if cache_store.nil?

      cached_response = cache_store[self.hash]

      if cached_response.nil?
        get_fresh_response
      elsif cached_response.expired?
        if cached_response.can_be_validated?
          get_validated_response_for(cached_response)
        else
          get_fresh_response
        end
      else
        cached_response
      end
    end

    def cache(response)
      cache_store[self.hash] = response if response && response.cacheable?
    end
    
    #:nodoc:
    def get_fresh_response
      cache_store.delete self.hash

      response = invoke_without_cache_check
      
      cache(response)
      
      response
    end

    #:nodoc:
    def get_validated_response_for(cached_response)
      new_response = send_validation_request_for(cached_response)
      if new_response.code == "304"
        cached_response
      else
        cache(new_response)
        new_response
      end
    end

    #:nodoc:
    # Send a cache-validation request to the server. This would be the actual Get request with extra cache-validation headers.
    # If a 304 (Not Modified) is received, Wrest would use the cached_response itself. Otherwise the new response is cached and used.
    def send_validation_request_for(cached_response)
      last_modified = cached_response.last_modified
      etag = cached_response.headers["etag"]

      cache_validation_headers = {}
      cache_validation_headers["if-modified-since"] = last_modified unless last_modified.nil?
      cache_validation_headers["if-none-match"] = etag unless etag.nil?

      new_headers=headers.clone.merge cache_validation_headers
      new_options=options.clone.tap {|opts| opts.delete :cache_store }  # do not run this through the caching mechanism.

      new_request = Wrest::Native::Get.new(uri, parameters, new_headers, new_options)

      new_request.invoke
    end

    alias_method_chain :invoke, :cache_check
  end
end
