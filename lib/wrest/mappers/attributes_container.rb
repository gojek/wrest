# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Mappers #:nodoc:

  # Adds behaviour allowing a class to
  # contain attributes and providing support
  # for dynamic getters, setters and query methods.
  # If you're implementing your own initialize method
  # remember to delegate to the default initialize 
  # of AttributesContainer by invoking <tt>super(attributes)</tt>
  module AttributesContainer
    def self.included(klass) #:nodoc:
      klass.class_eval{ include AttributesContainer::InstanceMethods }
    end

    module InstanceMethods 
      # Sets up a class to_s act like
      # an attributes container by creating
      # two variables, @attributes and @interface.
      # Remember not to use these two variable names
      # when using AttributesContainer in your
      # own class.
      def initialize(attributes = {})
        @attributes = attributes.symbolize_keys
        @interface = Module.new
        self.extend @interface
      end

      def respond_to?(method_name, include_private = false)
        super(method_name, include_private) ? true : @attributes.include?(method_name.to_s.gsub(/(\?$)|(=$)/, '').to_sym)
      end

      # Creates getter, setter and query methods for
      # attributes on the first call.
      def method_missing(method_sym, *arguments)
        method_name = method_sym.to_s
        attribute_name = method_name.gsub(/(\?$)|(=$)/, '')

        if @attributes.include?(attribute_name.to_sym) || method_name.last == '='
          case method_name.last
          when '='
            @interface.module_eval "def #{attribute_name}=(value);@attributes[:#{attribute_name}] = value;end"
          when '?'
            @interface.module_eval "def #{attribute_name}?;not @attributes[:#{attribute_name}].nil?;end"
          else
            @interface.module_eval "def #{attribute_name};@attributes[:#{attribute_name}];end"
          end
          send(method_sym, *arguments)
        else
          super(method_sym, *arguments)
        end
      end
      
    end
  end
end
