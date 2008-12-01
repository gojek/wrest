module Wrest
  class Response
    def_delegators  :@http_response,  :code, :message, :body, :http_version, 
                    :[], :content_length, :content_type, :each_header, :each_name, :each_value, :fetch,
                    :get_fields, :key?, :type_params
    
    def initialize(http_response, translator_klass)
      @http_response = http_response
      @translator = translator_klass.new(http_response)
    end
  end
end