module Wrest
  module Mappers
    class ActiveResource < Wrest::Resource
      def self.resource_host(host_url)
        @@host_url = host_url
      end

      def self.translator(translator_klass)
        @@translator_klass = translator_klass
      end

      def initialize(attributes = {})
        translator_klass = attributes.delete('translator_klass') || @@translator_klass
        host_url = attributes.delete('host_url') || @@host_url
        super(translator_klass, host_url)
      end
    end
  end
end



