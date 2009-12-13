# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Resource #:nodoc:
  # Resource::Base is the equivalent of ActiveResource::Base.
  # It is a REST client targetted at Rails REST apps.
  class Base
    include Wrest::Components::Container

    always_has      :id
    typecast        :id => as_integer
    attr_reader     :attributes

    def ==(other)
      return true if self.equal?(other)
      return false unless other.class == self.class
      return self.attributes == other.attributes
    end

    def hash
      id.hash
    end

    def to_xml(options={})
      attributes.to_xml({:root => self.class.resource_name.gsub('_', '-')}.merge(options))
    end

    class << self
      def inherited(klass)
        klass.set_resource_name klass.name
      end

      # Allows the resource name to be configured and creates
      # a getter method for it.
      # This is a useful feature when using anonymous classes like
      # we often do while writing tests.
      # By default, the resource name is set to the name of the class.
      def set_resource_name(resource_name)
        self.class_eval "def self.resource_name; '#{resource_name.to_s.underscore}';end"
      end

      # Allows the host url at which the resource is found to be configured
      # and creates a getter method for it.
      # For example in the url
      #  http://localhost:3000/users/1/settings
      # you would set
      #  http://localhost:3000
      # as the host url.
      def set_host(host)
        self.class_eval "def self.host; '#{host}';end"
      end

      def set_default_format(format)
        self.class_eval "def self.default_format; '#{format.to_s}';end"
      end

      def set_redirect_handler(method_object)
      end

      def resource_collection_name
        @resource_collection_name ||= "#{resource_name.underscore.pluralize}"
      end

      def find_one_uri_template
        @find_one_template ||= Wrest::UriTemplate.new(':host/:resource_collection_name/:id.:format')
      end

      def find(id)
        response = find_one_uri_template.to_uri(
          :host => host,
          :resource_collection_name => resource_collection_name,
          :id => id,
          :format => default_format
        ).get
        self.new(response.deserialise.mutate_using(
          Wrest::Components::Mutators.chain(:xml_mini_type_caster, :camel_to_snake_case)
        ).shift.last)
      end

      def create(attributes = {})
        response = Wrest::UriTemplate.new(':host/:resource_collection_name.:format').to_uri(
          :host => host,
          :resource_collection_name => resource_collection_name,
          :format => default_format
        ).post(self.new(attributes).to_xml, 'Content-Type' => "application/#{default_format}")

        self.new(response.deserialise.mutate_using(
          Wrest::Components::Mutators.chain(:xml_mini_type_caster, :camel_to_snake_case)
        ).shift.last)
      end
    end
  end
end
