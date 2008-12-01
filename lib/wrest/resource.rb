module Wrest
  class Resource
    attr_reader :translator_klass, :host_url
    
    def initialize(translator_klass, host_url)
      @translator_klass = translator_klass
      @host_url = host_url
    end
    
    def get(resource_path, headers = {})
      Response.new uri(resource_path).get(headers)
    end
  
    def put(resource_path, body = '', headers = {})
      Response.new uri(resource_path).put(body, headers)
    end
  
    def post(resource_path, body = '', headers = {})
      Response.new uri(resource_path).post(body, headers)
    end
  
    def delete(resource_path, headers = {})
      Response.new uri(resource_path).delete(headers)
    end
    
    def uri(resource_path)
      Uri.new(host_url+resource_path)
    end
  end
end