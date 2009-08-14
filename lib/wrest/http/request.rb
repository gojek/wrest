# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Http
  class Request
    attr_reader :http_request, :uri, :body, :headers, :username, :password, :follow_redirects
    # Valid tuples for the options are:
    # :username => String, defaults to nil
    # :password => String, defaults to nil
    # :follow_redirects => Boolean, defaults to true for Get, false for anything else
    def initialize(wrest_uri, http_request_klass, parameters = {}, body = nil, headers = {}, options = {})
      @uri = wrest_uri
      @headers = headers.stringify_keys
      @http_request = http_request_klass.new(parameters.empty? ? wrest_uri.full_path : "#{wrest_uri.full_path}?#{parameters.to_query}", @headers)
      @body = body
      @options = options
      @username = options[:username]
      @password = options[:password]
      @follow_redirects = options[:follow_redirects]
    end

    # Makes a request and returns a Wrest::Http::Response. 
    # Data about the request is and logged to Wrest.logger
    def invoke
      response = nil

      prefix = "#{http_request.method} #{http_request.hash}"
      http_request.basic_auth username, password

      Wrest.logger.debug "--> (#{prefix}) #{@uri.protocol}://#{@uri.host}:#{@uri.port}#{@http_request.path}"
      time = Benchmark.realtime { response = Wrest::Http::Response.new( http.request(@http_request, @body) ) }
      Wrest.logger.debug "<-- (#{prefix}) %d %s (%d bytes %.2fs)" % [response.code, response.message, response.body ? response.body.length : 0, time]

      @follow_redirects ? response.follow(@options) : response
    end

    private
    def http
      http = Net::HTTP.new(@uri.host, @uri.port)
      if @uri.https?
        http.use_ssl     = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http
    end
  end
end
