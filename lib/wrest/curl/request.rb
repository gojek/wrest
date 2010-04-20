# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Curl
    # This represents a HTTP request. Typically you will never need to instantiate
    # one of these yourself - you can use one of the more conveient APIs via Wrest::Uri
    # or Wrest::Curl::Get etc. instead.
    class Request
      attr_reader :http_request, :uri, :body, :headers, :username, :password, :follow_redirects,
      :follow_redirects_limit, :timeout, :connection, :parameters, :auth_type
      # Valid tuples for the options are:
      #   :username => String, defaults to nil
      #   :password => String, defaults to nil
      #   :follow_redirects => Boolean, defaults to true for Get, false for anything else
      #   :follow_redirects_limit => Integer, defaults to 5. This is the number of redirects
      #                              that Wrest will automatically follow before raising an
      #                              Wrest::Exceptions::AutoRedirectLimitExceeded exception.
      #                              For example, if you set this to 1, the very first redirect
      #                              will raise the exception.
      #   :timeout => The period, in seconds, after which a Timeout::Error is raised
      #               in the event of a connection failing to open. Defaulted to 60 by Uri#create_connection.
      #   :connection => The HTTP Connection object to use. This is how a keep-alive connection can be
      #                  used for multiple requests. Not yet fully implemented for Curl.
      #
      # Curl specific options:
      #   :auth_type => This is a curl specific option and can be one of :basic, :digest, or :any. The default is :basic.
      def initialize(wrest_uri, http_verb, parameters = {}, body = nil, headers = {}, options = {})
        @uri = wrest_uri
        @headers = headers.stringify_keys
        @parameters = parameters
        @body = body

        @options = options.clone
        @auth_type = @options[:auth_type] || :basic
        @username = @options[:username]
        @password = @options[:password]
        @follow_redirects = (@options[:follow_redirects] ||= false)

        @follow_redirects_limit = (@options[:follow_redirects_limit] ||= 5)
        @timeout = @options[:timeout] || 60
        @connection = @options[:connection]

        @http_request = Patron::Request.new
        @http_request.action = http_verb
        @http_request.upload_data = body
        @http_request.headers = headers
        @http_request.username = username
        @http_request.password = password
        @http_request.auth_type = auth_type
        @http_request.url = parameters.empty? ? uri.to_s : "#{uri.to_s}?#{parameters.to_query}"
        @http_request.max_redirects = follow_redirects_limit if follow_redirects
        @http_request.timeout = @timeout
      end

      # Makes a request and returns a Wrest::Http::Response.
      # Data about the request is and logged to Wrest.logger
      # The log entry contains the following information:
      #
      #   --> indicates a request
      #   <-- indicates a response
      #
      # The type of request is mentioned in caps, followed by a hash
      # uniquely uniquely identifying a particular request/response pair.
      # In a multi-process or multi-threaded scenario, this can be used
      # to identify request-response pairs.
      #
      # The request hash is followed by a connection hash; requests using the
      # same connection (effectively a keep-alive connection) will have the
      # same connection hash.
      #
      # This is followed by the response code, the payload size and the time taken.
      def invoke
        response = nil

        @connection ||= Patron::Session.new
        raise ArgumentError, "Empty URL" if http_request.url.empty?

        prefix = "#{http_request.action.to_s.upcase} #{http_request.hash} #{connection.hash}"

        Wrest.logger.debug "--> (#{prefix}) #{http_request.url}"
        time = Benchmark.realtime { response =  Wrest::Curl::Response.new(connection.handle_request(http_request))}
        Wrest.logger.debug "<-- (#{prefix}) %s (%d bytes %.2fs)" % [response.message, response.body ? response.body.length : 0, time]

        response
      rescue Patron::TimeoutError => e
        raise Wrest::Exceptions::Timeout.new(e)
      end
    end
  end
end
