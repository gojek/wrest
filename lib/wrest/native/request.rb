# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Native
  # This represents a HTTP request. Typically you will never need to instantiate
  # one of these yourself - you can use one of the more conveient APIs via Wrest::Uri
  # or Wrest::Native::Get etc. instead.
  class Request
    attr_reader :http_request, :uri, :body, :headers, :username, :password, :follow_redirects,
                :follow_redirects_limit, :follow_redirects_count, :timeout, :connection, :parameters, :cache_store, :verify_mode, :options
    # Valid tuples for the options are:
    #   :username => String, defaults to nil
    #   :password => String, defaults to nil
    #   :follow_redirects => Boolean, defaults to true for Get, false for anything else
    #   :follow_redirects_limit => Integer, defaults to 5. This is the number of redirects
    #                              that Wrest will automatically follow before raising an
    #                              Wrest::Exceptions::AutoRedirectLimitExceeded exception.
    #                              For example, if you set this to 1, the very first redirect
    #                              will raise the exception.
    #   :follow_redirects_count => Integer, defaults to 0. This is a count of the hops made to
    #                              get to this request and increases by one for every redirect 
    #                              until the follow_redirects_limit is hit. You should never set
    #                              this option yourself.
    #   :timeout => The period, in seconds, after which a Timeout::Error is raised 
    #               in the event of a connection failing to open. Defaulted to 60 by Uri#create_connection.
    #   :connection => The HTTP Connection object to use. This is how a keep-alive connection can be
    #                  used for multiple requests.
    #   :verify_mode => The  verification mode to be used for Net::HTTP https connections. Defaults to OpenSSL::SSL::VERIFY_PEER
    #   :cache_store => The object which should be used as cache store for cacheable responses. If not supplied, caching will be disabled.
    #   :detailed_http_logging => nil/$stdout/$stderr or File/Logger/IO object. Defaults to nil (recommended).
    #   :callback => A Hash whose keys are the response codes (or Range of response codes),
    #                        and the values are the callback functions to be executed.
    #                        eg: { <response code> => lambda { |response| some_operation } }
    #
    # *WARNING* : detailed_http_logging causes a serious security hole. Never use it in production code.
    #
    def initialize(wrest_uri, http_request_klass, parameters = {}, body = nil, headers = {}, options = {})
      @uri = wrest_uri
      @headers = headers.stringify_keys
      @parameters = parameters
      @body = body
      @options = options.clone
      @username = @options[:username]
      @password = @options[:password]
      @follow_redirects = (@options[:follow_redirects] ||= false)
      @follow_redirects_count = (@options[:follow_redirects_count] ||= 0)
      @follow_redirects_limit = (@options[:follow_redirects_limit] ||= 5)
      @timeout = @options[:timeout]
      @connection = @options[:connection]
      @http_request = self.build_request(http_request_klass, @uri, @parameters, @headers)
      @cache_store = options[:cache_store]
      @verify_mode = @options[:verify_mode]
      @detailed_http_logging = options[:detailed_http_logging]
      @callback = @options[:callback] || Wrest::Callback.new({})
      @callback = @callback.merge(Wrest::Callback.new(@options[:callback_block] || {}))
    end

    # Makes a request, runs the appropriate callback if any and
    # returns a Wrest::Native::Response.
    # 
    # Data about the request is and logged to Wrest.logger
    # The log entry contains the following information:
    #
    #   <- indicates a request
    #   -> indicates a response
    #
    # The type of request is mentioned in caps, followed by a hash 
    # uniquely identifying a particular request/response pair.
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
      @connection ||= @uri.create_connection({:timeout => timeout, :verify_mode => @verify_mode})
      @connection.set_debug_output @detailed_http_logging
      http_request.basic_auth username, password unless username.nil? || password.nil?

      prefix = "#{http_request.method} #{self.hash} #{@connection.hash}"
      
      Wrest.logger.debug "<- (#{prefix}) #{@uri.protocol}://#{@uri.host}:#{@uri.port}#{@http_request.path}"
      time = Benchmark.realtime { response = Wrest::Native::Response.new( do_request ) }
      Wrest.logger.debug "-> (#{prefix}) %d %s (%d bytes %.2fs)" % [response.code, response.message, response.body ? response.body.length : 0, time]

      execute_callback_if_any(response)
      
      @follow_redirects ? response.follow(@options) : response
    rescue Timeout::Error => e
      raise Wrest::Exceptions::Timeout.new(e)
    end

    #:nodoc:
    def build_request(request_klass, uri, parameters, headers)
      if(!uri.query.empty?)
        request_klass.new(parameters.empty? ? "#{uri.uri_path}?#{uri.query}" : "#{uri.uri_path}?#{uri.query}&#{parameters.to_query}", headers)
      else
        request_klass.new(parameters.empty? ? "#{uri.uri_path}" : "#{uri.uri_path}?#{parameters.to_query}", headers)
      end
    end
  
    #:nodoc:
    def do_request
      @connection.request(@http_request, @body)
    end

    #:nodoc:
    def execute_callback_if_any(actual_response)
      @callback.execute(actual_response)
    end
  end
end
