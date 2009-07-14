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
  # Note that a Wrest::Uri is immutable.
  #
  # Basic HTTP Authentication is supported.
  # Example:
  #  "http://kaiwren:fupuppies@coathangers.com/portal/1".to_uri
  #  "http://coathangers.com/portal/1".to_uri(:username => 'kaiwren', :password => 'fupuppies')
  # 
  # The second form is preferred as it can handle passwords with special characters like ^ and @
  class Uri
    attr_reader :uri, :username, :password
    def initialize(uri_string, options = {})
      @options = options
      @uri_string = uri_string.clone
      @uri = URI.parse(uri_string)
      @username = options[:username] || @uri.user
      @password = options[:password] || @uri.password
    end
    
    # Build a new Wrest::Uri by appending _path_ to
    # the current uri. If the original Wrest::Uri
    # has a username and password, that will be
    # copied to the new Wrest::Uri as well.
    #
    # Example:
    #  uri = "https://localhost:3000/v1".to_uri
    #  uri['/oogas/1'].get
    #
    # To change the username and password on the new
    # instance, simply pass them as an options map.
    #
    # Example:
    #  uri = "https://localhost:3000/v1".to_uri(:username => 'foo', :password => 'bar')
    #  uri['/oogas/1', {:username => 'meh', :password => 'baz'}].get
    def [](path, options = nil)
      Uri.new(@uri_string+path, options || @options)
    end
    
    def eql?(other)
      self == other
    end
    
    def ==(other)
      return false if other.class != self.class
      return other.uri == self.uri && self.username == other.username && self.password == other.password
    end
    
    def hash
      @uri.hash + @username.hash + @password.hash + 20090423
    end
    
    # Make a HTTP get request to this URI.
    # Remember to escape all parameter strings using URI.escape 
    def get(parameters = {}, headers = {})
      do_request Net::HTTP::Get.new(parameters.empty? ? @uri.request_uri : "#{@uri.request_uri}?#{parameters.to_query}", headers.stringify_keys)
    end

    def put(body = '', headers = {})
      do_request Net::HTTP::Put.new(@uri.request_uri, headers.stringify_keys), body.to_s
    end

    def post(body = '', headers = {})
      do_request Net::HTTP::Post.new(@uri.request_uri, headers.stringify_keys), body.to_s
    end

    def delete(parameters = {}, headers = {})
      do_request Net::HTTP::Delete.new(parameters.empty? ? @uri.request_uri : "#{@uri.request_uri}?#{parameters.to_query}", headers.stringify_keys)
    end

    def options
      do_request Net::HTTP::Options.new(@uri.request_uri)
    end
    
    def do_request(http_request, *args)
      response = nil

      prefix = "#{http_request.method} #{http_request.hash}"
      http_request.basic_auth username, password

      Wrest.logger.debug "--> (#{prefix}) #{@uri.scheme}://#{@uri.host}:#{@uri.port}#{http_request.path} #{args.inspect}"
      time = Benchmark.realtime { response = Wrest::Response.new(http.request(http_request, *args)) }
      Wrest.logger.debug "<-- (#{prefix}) %d %s (%d bytes %.2fs)" % [response.code, response.message, response.body ? response.body.length : 0, time]

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
