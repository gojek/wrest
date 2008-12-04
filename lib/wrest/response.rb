module Wrest
  class Response
    extend Forwardable
    def_delegators  :@http_response,  :code, :message, :body, :http_version, 
                    :[], :content_length, :content_type, :each_header, :each_name, :each_value, :fetch,
                    :get_fields, :key?, :type_params
    
    def initialize(http_response)
      @http_response = http_response
    end
    
    def deserialise
      Wrest::Translators.build(@http_response).deserialise
    end
  end
end