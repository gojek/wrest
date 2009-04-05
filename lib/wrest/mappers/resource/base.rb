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
    include Wrest::Mappers::AttributesContainer
    attr_reader :attributes

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
        self.class_eval "def self.resource_name; '#{resource_name}';end"
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

      def resource_path
        @resource_path ||= "/#{resource_name.underscore.pluralize}"
      end

      def resource_url
        "#{host}#{resource_path}"
      end
      
      def find_all
      end

      def find(id)
        response_hash = "#{resource_url}/#{id}".to_uri.get.deserialise
        resource_type = response_hash.keys.first
        if(resource_type.underscore.camelize == self.name)
          self.new(response_hash[resource_type].first)
        else
          response_hash
        end
      end

      def objectify(hash)
      end
    end
  end
end
