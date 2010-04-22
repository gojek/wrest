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
    attr_reader :uri, :username, :password, :uri_string
        
    # See Wrest::Http::Request for the available options and their default values.
    def initialize(uri_string, options = {})
      @options = options
      @uri_string = uri_string.clone
      @uri = URI.parse(uri_string)
      @username = (@options[:username] ||= @uri.user)
      @password = (@options[:password] ||= @uri.password)
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
    # that creates a Wrest::Http::Get, executes it and returns a Wrest::Http::Response.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def get(parameters = {}, headers = {})
      Http::Get.new(self, parameters, headers, @options).invoke
    end

    # Make a PUT request to this URI. This is a convenience API
    # that creates a Wrest::Http::Put, executes it and returns a Wrest::Http::Response.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def put(body = '', headers = {}, parameters = {})
      Http::Put.new(self, body.to_s, headers, parameters, @options).invoke
    end

    # Makes a POST request to this URI. This is a convenience API
    # that creates a Wrest::Http::Post, executes it and returns a Wrest::Http::Response.
    # Note that sending an empty body will blow up if you're using libcurl.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def post(body = '', headers = {}, parameters = {})
      Http::Post.new(self, body.to_s, headers, parameters, @options).invoke
    end
    
    # Makes a POST request to this URI. This is a convenience API
    # that mimics a form being posted; some allegly RESTful APIs like FCBK require 
    # this.
    #
    # Form encoding involves munging the parameters into a string and placing them
    # in the body, as well as setting the Content-Type header to
    # application/x-www-form-urlencoded
    def post_form(parameters = {}, headers = {})
      headers = headers.merge(Wrest::H::ContentType => Wrest::T::FormEncoded)
      body = parameters.to_query
      Http::Post.new(self, body, headers, {}, @options).invoke
    end

    # Makes a DELETE request to this URI. This is a convenience API
    # that creates a Wrest::Http::Delete, executes it and returns a Wrest::Http::Response.
    #
    # Remember to escape all parameter strings if necessary, using URI.escape
    def delete(parameters = {}, headers = {})
      Http::Delete.new(self, parameters, headers, @options).invoke
    end

    # Makes an OPTIONS request to this URI. This is a convenience API
    # that creates a Wrest::Http::Options, executes it and returns the Wrest::Http::Response.
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
