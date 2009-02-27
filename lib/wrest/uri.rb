module Wrest
  class Uri
    def initialize(uri_string)
      @uri = URI.parse(uri_string)
    end

    def get(headers = {})
      response http.get(@uri.request_uri, headers)
    end

    def put(body = '', headers = {})
      response http.put(@uri.request_uri, body.to_s, headers)
    end

    def post(body = '', headers = {})
      response http.post(@uri.request_uri, body.to_s, headers)
    end

    def delete(headers = {})
      response http.delete(@uri.request_uri, headers)
    end

    def https?
      @uri.is_a?(URI::HTTPS)
    end

    def http
      http             = Net::HTTP.new(@uri.host, @uri.port)
      http.use_ssl     = true if https?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE if http.use_ssl
      http
    end

    def response(http_response)
      Wrest::Response.new http_response
    end
  end
end
