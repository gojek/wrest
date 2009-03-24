# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Mappers::Resource #:nodoc:
  # Resource::Base is the equivalent of ActiveResource::Base.
  # It is a REST client targetted at Rails REST apps.
  class Base
    class << self
      def host=(host_url)
        self.class_eval "def self.host; '#{host_url.clone}';end"
      end

      def resource_path
        @resource_path ||= "/#{self.name.underscore.pluralize}"
      end

      def find_all
        Wrest::Uri.new("#{host}#{resource_path}").get.deserialise
      end

      def find(id)
        response_hash = Wrest::Uri.new("#{host}#{resource_path}/#{id}").get.deserialise
        resource_type = response_hash.keys.first
        if(resource_type.underscore.camelize == self.name)
          self.new(response_hash[resource_type])
        else
          response_hash
        end
      end
    end
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes.symbolize_keys
      @interface = Module.new
      self.extend @interface
    end

    def respond_to?(method_name, include_private = false)
      super(method_name, include_private) ? true : attributes.include?(method_name.to_s.gsub(/(\?$)|(=$)/, '').to_sym)
    end

    def method_missing(method_sym, *arguments)
      method_name = method_sym.to_s
      attribute_name = method_name.gsub(/(\?$)|(=$)/, '')
      
      if attributes.include?(attribute_name.to_sym) || method_name.last == '='
        case method_name.last
        when '='
          @interface.module_eval "def #{attribute_name}=(value);attributes[:#{attribute_name}] = value;end"
        when '?'
          @interface.module_eval "def #{attribute_name}?;not attributes[:#{attribute_name}].nil?;end"
        else
          @interface.module_eval "def #{attribute_name};attributes[:#{attribute_name}];end"
        end
        send(method_sym, *arguments)
      else
        super(method_sym, *arguments)
      end
    end
  end
end
