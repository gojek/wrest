module Wrest
  class Resource
    attr_reader :host_url
    
    def initialize(host_url)
      @host_url = host_url
    end
    
    def request(resource_path, body = '', header = {})
      Wrest::Request.new uri(resource_path), body, header
    end
    
    def uri(resource_path)
      Wrest::Uri.new(host_url+resource_path)
    end
  end
end