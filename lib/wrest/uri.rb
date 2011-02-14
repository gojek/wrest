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
  #
  # You can find examples that use real APIs (like delicious) under the wrest/examples directory.
  class Uri
    attr_reader :uri, :username, :password, :uri_string, :uri_path, :query 
        
    # See Wrest::Native::Request for the available options and their default values.
    def initialize(uri_string, options = {})
        @options = options.clone
        @uri_string = uri_string.to_s
        @uri = URI.parse(@uri_string)
        uri_scheme = URI.split(@uri_string)
        @uri_path = uri_scheme[-4].split('?').first || ''
        @uri_path = (@uri_path.empty? ? '/' : @uri_path) 
        @query = uri_scheme[-2] || ''
        @username = (@options[:username] ||= @uri.user)
        @password = (@options[:password] ||= @uri.password)
        @options[:callback] = Callback.new(@options[:callback]) if @options[:callback]
    end 
    
    def to_template(pattern)
      template_pattern = URI.join(uri_string,pattern).to_s
      UriTemplate.new(template_pattern, @options)
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
      Uri.new(uri + File.join(uri_path, path), options || @options)
    end
    
    # Clones a Uri, building a new instance with exactly the same uri string.
    # You can however change the Uri options or add new ones.
    def clone(opts = {})
      Uri.new(@uri_string, @options.merge(opts))
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
    
    # This produces exactly the same string as the Wrest::Uri was constructed with.
    # If the orignial URI contained a HTTP username and password, that too will
    # show up, so be careful if using this for logging.
    def to_s
      uri_string
    end
    
    # Make a GET request to this URI. This is a convenience API
    # that creates a Wrest::Native::Get, executes it and returns a Wrest::Native::Response.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def get(parameters = {}, headers = {}, &block)
      Http::Get.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Returns a Uri object that uses threads to perform asynchronous requests.
    def using_threads
      options = @options.clone
      options[:asynchronous_backend] = Wrest::AsyncRequest::ThreadBackend.new
      Uri.new(uri_string, options)
    end

    # Returns a Uri object that uses eventmachine to perform asynchronous requests.
    def using_em
      options = @options.clone
      Wrest::AsyncRequest.enable_em
      options[:asynchronous_backend] = Wrest::AsyncRequest::EventMachineBackend.new
      Uri.new(uri_string, options)
    end

    # Returns a Uri object that uses hash for caching responses.
    def using_hash
      options = @options.clone
      options[:cache_store] = Hash.new
      Uri.new(uri_string, options)
    end

    # Returns a Uri object that uses memcached for caching responses.
    def using_memcached
      options = @options.clone
      Wrest::Caching.enable_memcached
      options[:cache_store] = Wrest::Caching::Memcached.new
      Uri.new(uri_string, options)
    end

    def disable_cache
      options = @options.clone
      Wrest::Caching.enable_memcached
      options[:disable_cache] = true 
      Uri.new(uri_string, options)
    end

    # Make a GET request to this URI. This is a convenience API
    # that creates a Wrest::Native::Get.
    # 
    # Remember to escape all parameter strings if necessary, using URI.escape
    #
    # Note: get_async does not return a response and the response should be accessed through callbacks.
    # This implementation of asynchronous get is very naive and should not be used in production.
    # Stable implementation of asynchronous requests involving thread pools would be out soon.
    def get_async(parameters = {}, headers = {}, &block)
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::Get.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options))
      nil
    end

    # Make a PUT request to this URI. This is a convenience API
    # that creates a Wrest::Native::Put, executes it and returns a Wrest::Native::Response.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def put(body = '', headers = {}, parameters = {}, &block)
      Http::Put.new(self, body.to_s, headers, parameters, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Make a PUT request to this URI. This is a convenience API
    # that creates a Wrest::Native::Put.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    #
    # Note: put_async does not return a response and the response should be accessed through callbacks.
    # This implementation of asynchronous put is very naive and should not be used in production.
    # Stable implementation of asynchronous requests involving thread pools would be out soon.
    def put_async(body = '', headers = {}, parameters = {}, &block)
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::Put.new(self, body.to_s, headers, parameters, block ? @options.merge(:callback_block => block) : @options))
      nil
    end

    # Makes a POST request to this URI. This is a convenience API
    # that creates a Wrest::Native::Post, executes it and returns a Wrest::Native::Response.
    # Note that sending an empty body will blow up if you're using libcurl.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def post(body = '', headers = {}, parameters = {}, &block)
      Http::Post.new(self, body.to_s, headers, parameters, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Makes a POST request to this URI. This is a convenience API
    # that creates a Wrest::Native::Post.
    # Note that sending an empty body will blow up if you're using libcurl.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    #
    # Note: post_async does not return a response and the response should be accessed through callbacks.
    # This implementation of asynchronous post is very naive and should not be used in production.
    # Stable implementation of asynchronous requests involving thread pools would be out soon.
    def post_async(body = '', headers = {}, parameters = {}, &block)
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::Post.new(self, body.to_s, headers, parameters, block ? @options.merge(:callback_block => block) : @options))
      nil
    end
    
    # Makes a POST request to this URI. This is a convenience API
    # that mimics a form being posted; some allegly RESTful APIs like FCBK require 
    # this.
    #
    # Form encoding involves munging the parameters into a string and placing them
    # in the body, as well as setting the Content-Type header to
    # application/x-www-form-urlencoded
    def post_form(parameters = {}, headers = {}, &block)
      headers = headers.merge(Wrest::H::ContentType => Wrest::T::FormEncoded)
      body = parameters.to_query
      Http::Post.new(self, body, headers, {}, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Makes a POST request to this URI. This is a convenience API
    # that mimics a form being posted; some allegly RESTful APIs like FCBK require 
    # this.
    #
    # Form encoding involves munging the parameters into a string and placing them
    # in the body, as well as setting the Content-Type header to
    # application/x-www-form-urlencoded
    #
    # Note: post_form_async does not return a response and the response should be accessed through callbacks.
    # This implementation of asynchronous post_form is very naive and should not be used in production.
    # Stable implementation of asynchronous requests involving thread pools would be out soon.
    def post_form_async(parameters = {}, headers = {}, &block)
      headers = headers.merge(Wrest::H::ContentType => Wrest::T::FormEncoded)
      body = parameters.to_query
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::Post.new(self, body, headers, {}, block ? @options.merge(:callback_block => block) : @options))
      nil
    end

    # Makes a DELETE request to this URI. This is a convenience API
    # that creates a Wrest::Native::Delete, executes it and returns a Wrest::Native::Response.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def delete(parameters = {}, headers = {}, &block)
      Http::Delete.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options).invoke
    end

    # Makes a DELETE request to this URI. This is a convenience API
    # that creates a Wrest::Native::Delete.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    #
    # Note: delete_async does not return a response and the response should be accessed through callbacks.
    # This implementation of asynchronous delete is very naive and should not be used in production.
    # Stable implementation of asynchronous requests involving thread pools would be out soon.
    def delete_async(parameters = {}, headers = {}, &block)
      (@options[:asynchronous_backend] || Wrest::AsyncRequest.default_backend).execute(Http::Delete.new(self, parameters, headers, block ? @options.merge(:callback_block => block) : @options))
      nil
    end

    # Makes an OPTIONS request to this URI. This is a convenience API
    # that creates a Wrest::Native::Options, executes it and returns the Wrest::Native::Response.
    def options
      Http::Options.new(self, @options).invoke
    end

    def https? 
      @uri.is_a?(URI::HTTPS)
    end

    # Provides the full path of a request.
    # For example, for
    #  http://localhost:3000/demons/1/chi?sort=true
    # this would return
    #  /demons/1/chi?sort=true
    def full_path
      uri.request_uri
    end

    def protocol
      uri.scheme
    end
    
    def host
      uri.host
    end
    
    def port
      uri.port
    end
    
    include Http::ConnectionFactory
  end
end
