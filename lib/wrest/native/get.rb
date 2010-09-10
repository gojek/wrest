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

    def get_cached_response
      response = nil
      if cache_store.has_key?(@uri)
        response = cache_store.fetch(@uri)
      end
      response
    end

    def cache_response(response)
      cache_store[@uri] = response
    end

    alias_method_chain :invoke, :cache_check
  end
end
