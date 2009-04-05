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
      
      def set_host(host_url)
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
      
      def objectify(hash)
      end
    end
  end
end
