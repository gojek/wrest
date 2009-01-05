module Wrest
  class Resource    
    attr_reader :uri
    
    def initialize(uri)
      @uri = uri
    end
    
    protected
    def request(body = '', header = {})
      Wrest::Request.new uri, body, header
    end
  end
end