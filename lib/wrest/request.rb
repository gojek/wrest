module Wrest
  class Request
    attr_reader :uri, :body, :header
    
    def initialize(uri, body = '', header = {})
      @uri = uri
      @body = body
      @headers = header
    end

    def get
      uri.get(header)
    end

    def put
      uri.put(body, header)
    end

    def post
      uri.post(body, header)
    end

    def delete
      uri.delete(header)
    end
  end
end
