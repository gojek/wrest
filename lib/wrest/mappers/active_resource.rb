module Wrest
  module Mappers
    class ActiveResource < Wrest::Resource
      class << self
        def resource_host(host_url)
          @resource_host = host_url
        end
        
        def default_translator(translator_klass)
          @translator_klass = translator_klass
        end
      end

      def initialize(attributes = {})
        translator_klass = attributes.delete['translator_klass'] || @@translator_klass
        super
      end
      
      def find_all
        
      end
    end
  end
end
  
  
  