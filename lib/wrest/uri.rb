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
    attr_reader :uri
    def initialize(uri_string)
      @uri = URI.parse(uri_string)
    end
    
    def eql?(other)
      self == other
    end
    
    def ==(other)
      return false if other.class != self.class
      return other.uri == self.uri
    end
    
    def hash
      self.uri.hash + self.class.object_id
    end
    
    # Make a HTTP get request to this URI.
    # Remember to escape the parameter strings using URI.escape 
    def get(parameters = {}, headers = {})
      do_request 'get', parameters.empty? ? @uri.request_uri : "#{@uri.request_uri}?#{parameters.to_query}", headers.stringify_keys
    end

    def put(body = '', headers = {})
      do_request 'put', @uri.request_uri, body.to_s, headers.stringify_keys
    end

    def post(body = '', headers = {})
      do_request 'post', @uri.request_uri, body.to_s, headers.stringify_keys
    end

    def delete(headers = {})
      do_request 'delete', @uri.request_uri, headers.stringify_keys
    end
    
    def do_request(method, url, *args)
      response = nil

      Wrest.logger.info  "#{method} -> #{url}"
      time = Benchmark.realtime { response = Wrest::Response.new(http.send(method, url, *args)) }
      Wrest.logger.info "--> %d %s (%d %.2fs)" % [response.code, response.message, response.body ? response.body.length : 0, time]

      response
    end
    
    def https?
      @uri.is_a?(URI::HTTPS)
    end

    def http
      http = Net::HTTP.new(@uri.host, @uri.port)
      if https?
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end
  end
end
