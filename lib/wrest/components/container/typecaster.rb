# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Components::Container
    # An extension to AttributesContainer that adds support for
    # specifying how the values associated with certain attribute keys
    # should be typecast.
    #
    # This extension can be used in situations where the attributes
    # hash consists of just strings with no associated tup information.
    # For example, params recieved from a web browser may contain
    # attributes like
    #  'id' => '4', 'dateofbirth' => '1984-04-05'
    # and we'd like to have these cast to an integer and a date
    # respectively, rather than have to deal with them as strings.
    module Typecaster
      def self.included(klass) #:nodoc:
        klass.extend Typecaster::ClassMethods
        klass.class_eval{ include Typecaster::InstanceMethods }
        klass.alias_method_chain  :initialize,  :typecasting
      end
      
      module Helpers
        def as_base64Binary
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['base64Binary']
        end

        def as_boolean
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['boolean']
        end

        def as_decimal
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['decimal']
        end

        def as_date
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['date']
        end

        def as_datetime
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['datetime']
        end

        def as_float
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['float']
        end

        def as_integer
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['integer']
        end

        def as_symbol
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['symbol']
        end

        def as_yaml
          ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING['yaml']
        end
      end
        
      module ClassMethods
        # Accepts a set of attribute-name/lambda pairs which are used
        # to typecast string values injected through the constructor.
        # Typically needed when populating an +AttributesContainer+
        # directly from request params. Typecasting kicks in for
        # a given value _only_ if it is a String, Hash or Array, the
        # three classes that deserilisation can produce.
        #
        # Typecast information is inherited by subclasses; however be
        # aware that explicitly invoking +typecast+ in a subclass will
        # discard inherited typecast information leaving only the casts
        # defined in the subclass.
        #
        # Note that this _will_ increase the time needed to initialize
        # instances.
        #
        # Common typecasts such as integer, float, datetime etc. are
        # available through predefined helpers. See TypecastHelpers
        # for a full list.
        #
        # Example:
        #
        #  class Demon
        #    include Wrest::Components::AttributesContainer
        #    include Wrest::Components::AttributesContainer::Typecaster
        #
        #    typecast         :age          =>  as_integer,
        #                     :chi          =>  lambda{|chi| Chi.new(chi)}
        #  end
        #
        #  kai_wren = Demon.new('age' => '1500', 'chi' => '1024')
        #  kai_wren.age           # => 1500
        #  kai_wren.chi           # => #<Chi:0x113af8c @count="1024">
        def typecast(cast_map)
          @typecast_map = @typecast_map ? @typecast_map.merge(cast_map.symbolize_keys) : cast_map.symbolize_keys
        end

        def typecast_map #:nodoc:
          if defined?(@typecast_map)
            @typecast_map
          elsif superclass != Object && superclass.respond_to?(:typecast_map)
            superclass.typecast_map
          else
            {}
          end
        end
      end

      module InstanceMethods # :nodoc:
        def initialize_with_typecasting(attributes = {}) # :nodoc:
          initialize_without_typecasting(attributes)
          self.class.typecast_map.each do |key, typecaster|
            value = @attributes[key]
            @attributes[key] = typecaster.call(value) if (value.is_a?(String) || value.is_a?(Hash) || value.is_a?(Array))
          end
        end
      end
    end
  end
end
