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
      options[:cache_store] ||= {}
      super(
            wrest_uri, 
            Net::HTTP::Get, 
            parameters,
            nil,
            headers,
            options
          )
    end

    def ==(other)
      return true if self.equal?(other)
      return false unless other.class == self.class
      return true if self.uri == other.uri and
        self.parameters == other.parameters and
        self.username == other.username and
        self.password == other.password and
        self.verify_mode == other.verify_mode
    end

    def hash
      self.uri.hash + self.parameters.hash + self.username.hash + self.password.hash + self.verify_mode.hash + 20110106
    end
    
    #:nodoc:
    def invoke_with_cache_check
      cached_response = get_cached_response
      if cached_response.nil? then
        response = invoke_without_cache_check
        cache_response(response) if !response.nil? && response.cacheable?
        response
      else
        cached_response
      end
    end

    #:nodoc:
    def get_cached_response
      response = nil
      if cache_store.has_key?(self.hash)
        response = cache_store.fetch(self.hash)
      end
      response
    end

    #:nodoc:
    def cache_response(response)
      cache_store[self.hash] = response
    end

    alias_method_chain :invoke, :cache_check
  end
end
