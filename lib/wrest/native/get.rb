# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Native
    class Get < Request
      QUERY_PARAMS_SEPERATOR = '?'
      EMPTY_QUERY_PARAMS = ''

      attr_reader :cache_proxy

      def initialize(wrest_uri, parameters = {}, headers = {}, options = {})
        follow_redirects = options[:follow_redirects]
        options[:follow_redirects] = (follow_redirects.nil? ? true : follow_redirects)

        cache_store = (options[:cache_store] || Wrest::Caching.default_store) unless options[:disable_cache]
        @cache_proxy = Wrest::CacheProxy.new(self, cache_store)

        super(wrest_uri, Net::HTTP::Get, parameters, nil, headers, options)
      end

      # Checks equality between two Wrest::Native::Get objects.
      # Comparing two Wrest::Native::Get objects with identical values for the following properties would return True.
      #   uri, parameters, username, password and ssh verify_mode.
      def ==(other)
        return true if equal?(other)
        return false unless other.class == self.class
        return true if these_fields_are_equal(other)

        false
      end

      # Returns a hash value for this Wrest::Native::Get object.
      # Objects that returns true when compared using the == operator would return the same hash value also.
      def hash
        [uri, parameters, username, password, verify_mode].hash
      end

      # :nodoc:
      def invoke_with_cache_check
        cache_proxy.get
      end

      alias invoke_without_cache_check invoke
      alias invoke invoke_with_cache_check

      def build_request_without_cache_store(cache_validation_headers)
        new_headers = headers.clone.merge cache_validation_headers
        new_options = # do not run this through the caching mechanism.
          options.clone.tap do |opts|
            opts.delete :cache_store
            opts[:disable_cache] = true
          end
        Wrest::Native::Get.new(uri, parameters, new_headers, new_options)
      end

      def full_uri_string
        @uri.to_s + query_params_string
      end

      private

      def these_fields_are_equal(other)
        (uri == other.uri) &&
          (parameters == other.parameters) &&
          (username == other.username) &&
          (password == other.password) &&
          (verify_mode == other.verify_mode)
      end

      def query_params_string
        @parameters.any? ? QUERY_PARAMS_SEPERATOR + Utils.hash_to_param(@parameters) : EMPTY_QUERY_PARAMS
      end
    end
  end
end
