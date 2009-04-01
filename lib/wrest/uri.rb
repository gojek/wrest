# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest #:nodoc:
  # Wrest::Uri provides a simple api for
  # REST calls. String#to_uri is a convenience
  # method to build a Wrest::Uri from a string url.
  class Uri
    def initialize(uri_string)
      @uri = URI.parse(uri_string)
    end

    def get(parameters = {}, headers = {})
      Wrest.logger.debug  "GET -> #{@uri.request_uri}"
      response http.get(@uri.request_uri << '?' << parameters.to_query, headers.stringify_keys)
    end

    def put(body = '', headers = {})
      Wrest.logger.debug  "PUT -> #{@uri.request_uri}"
      response http.put(@uri.request_uri, body.to_s, headers)
    end

    def post(body = '', headers = {})
      Wrest.logger.debug  "POST -> #{@uri.request_uri}"
      response http.post(@uri.request_uri, body.to_s, headers)
    end

    def delete(headers = {})
      Wrest.logger.debug  "DELETE -> #{@uri.request_uri}"
      response http.delete(@uri.request_uri, headers)
    end

    def https?
      @uri.is_a?(URI::HTTPS)
    end

    def http
      http             = Net::HTTP.new(@uri.host, @uri.port)
      if https?
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end

    def response(http_response)
      Wrest::Response.new http_response
    end
  end
end
