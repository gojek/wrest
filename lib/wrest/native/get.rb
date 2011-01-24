# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Native
  class Get < Request

    attr_reader :cache_logic

    def initialize(wrest_uri, parameters = {}, headers = {}, options = {})
      follow_redirects = options[:follow_redirects]
      options[:follow_redirects] = (follow_redirects == nil ? true : follow_redirects)
      @cache_logic = Wrest::CacheLogic::new(self, options[:cache_store])
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
      false
    end

    # Returns a hash value for this Wrest::Native::Get object.
    # Objects that returns true when compared using the == operator would return the same hash value also.
    def hash
      self.uri.hash + self.parameters.hash + self.username.hash + self.password.hash + self.verify_mode.hash + 20110106
    end

    #:nodoc:
    def invoke_with_cache_check
      cache_logic.get
    end

    alias_method_chain :invoke, :cache_check
  end
end
