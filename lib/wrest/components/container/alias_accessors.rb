# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Components::Container
    module AliasAccessors
      def self.included(klass) #:nodoc:
        klass.extend AliasAccessors::ClassMethods
      end

      def self.build_aliased_attribute_getter(attribute_name, alias_name) #:nodoc:
        "def #{alias_name};#{attribute_name};end;"
      end

      def self.build_aliased_attribute_setter(attribute_name, alias_name) #:nodoc:
        "def #{alias_name}=(value);self.#{attribute_name}=value;end;"
      end

      def self.build_aliased_attribute_queryer(attribute_name, alias_name) #:nodoc:
        "def #{alias_name}?;self.#{attribute_name}?;end;"
      end
      
      module ClassMethods
        # Creates an alias set of getter, setter and query methods for 
        # attributes that aren't quite the way you'd like them to be; this
        # is especially useful when you have no control over the source web
        # sevice/resource.
        #
        # For example, lets say that a particular resource exposes a
        # User's age as 'a' and sex as 's'. Typically, you'd have to access it as
        # user.a and user.s whereas you's like to access it as user.age and user.sex.
        # This is where alias_accessors comes into the picture. Your User class would
        # look somethig like this:
        #
        #  class User
        #    include Wrest::Components::AttributesContainer
        #
        #    alias_accessors  :a => :age,
        #                     :s => :sex
        #  end
        # This would create the methods user.age, user.age= and user.age? which delegates
        # to user.a, user.a= and user.a? respectively.
        #
        # See examples/wow_realm_status.rb for a working example.
        # 
        # WARNING: If you try to create an alias with the same name as the attribute,
        # and then use it, you _will_ cause an infinite loop.
        def alias_accessors(alias_map)
          alias_map.each do |attribute_name, alias_name|
            self.class_eval(
            AliasAccessors.build_aliased_attribute_getter(attribute_name, alias_name) +
            AliasAccessors.build_aliased_attribute_setter(attribute_name, alias_name) +
            AliasAccessors.build_aliased_attribute_queryer(attribute_name, alias_name)
            )
          end
        end
      end
    end
  end
end
