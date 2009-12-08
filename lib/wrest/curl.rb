# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

gem 'patron', '=0.4.4'
require 'patron'

module Wrest #:nodoc:

  # Contains all HTTP protocol related classes such as
  # Get, Post, Request, Response etc. and uses Curl for
  # better performance, but only on CRuby and only on a *nix OS.
  module Curl
  end
end

module Patron
  class Session
    public :handle_request
  end

  class Response
    def initialize
      @header = {}
    end

    def headers
      @header
    end
    
    include Net::HTTPHeader
    private
    # Called by the C code to parse and set the headers
    def parse_headers(header_data)
      header_data.split(/\r\n/).each do |header|
        if header =~ %r|^HTTP/1.[01]|
          @status_line = header.strip
        else
          parts = header.split(':', 2)
          parts[1].strip! unless parts[1].nil?
          if headers.has_key?(parts[0])
            headers[parts[0]] << ",#{parts[1]}"
          else
            headers[parts[0]] = parts[1]
          end
        end
      end
    end
  end
end

require "#{WREST_ROOT}/wrest/curl/response"
require "#{WREST_ROOT}/wrest/curl/request"
require "#{WREST_ROOT}/wrest/curl/connection_factory"
# require "#{WREST_ROOT}/wrest/curl/get"
# require "#{WREST_ROOT}/wrest/curl/put"
# require "#{WREST_ROOT}/wrest/curl/post"
# require "#{WREST_ROOT}/wrest/curl/delete"
# require "#{WREST_ROOT}/wrest/curl/options"
# require "#{WREST_ROOT}/wrest/curl/session"
