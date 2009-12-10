# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Native
  # This class is a wrapper for a keep-alive HTTP connection. It simply passes the
  # same connection instance as an option to all Wrest::Http::Request instances created using it.
  #
  # If at any point the server closes an existing connection during a Session by returning a
  # Connection: Close header the current connection is destroyed and a fresh one created for the next
  # request.
  #
  # The Session constructor can accept either a String URI or a Wrest::Uri as a parameter. If you
  # need HTTP authentication, you should use a Wrest::Uri.
  class Session
    attr_reader :uri
    def initialize(uri)
      @uri = uri.is_a?(String) ? uri.to_uri : uri
      @default_headers = { StandardHeaders::Connection => StandardTokens::KeepAlive }

      yield(self) if block_given?
    end

    def connection
      @connection ||= @uri.create_connection
    end

    def get(path = '', parameters = {}, headers = {})
      maybe_destroy_connection @uri[path, {:connection => self.connection}].get(parameters, headers.merge(@default_headers))
    end

    def post(path = '', body = '', headers = {}, params = {})
      maybe_destroy_connection @uri[path, {:connection => self.connection}].post(body, headers.merge(@default_headers), params)
    end
    
    def put(path = '', body = '', headers = {}, params = {})
      maybe_destroy_connection @uri[path, {:connection => self.connection}].put(body, headers.merge(@default_headers), params)
    end

    def delete(path = '', parameters = {}, headers = {})
      maybe_destroy_connection @uri[path, {:connection => self.connection}].delete(parameters, headers.merge(@default_headers))
    end
    
    def maybe_destroy_connection(response)
      if response.connection_closed?
        Wrest.logger.warn "Connection #{@connection.hash} has been closed by the server"
        @connection = nil 
      end
      response
    end
  end
end
