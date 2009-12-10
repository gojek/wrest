# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest
  module Components
    # A mutator understands how to transform
    # one tuple(key/value pair) from a hash
    # into another
    module Mutators
      # All sublasses of Mutators::Base are automatically
      # registered here by underscored, symbolised class name.
      REGISTRY = {}
      
      # Makes referencing and chaining mutators easy.
      # 
      # Example:
      #  Mutators.chain(:xml_mini_type_caster, :camel_to_snake_case)
      # is equivalent to
      #  Wrest::Components::Mutators::XmlMiniTypeCaster.new(Wrest::Components::Mutators::CamelToSnakeCase.new)
      def self.chain(*mutator_keys)
        mutator_key = mutator_keys.pop
        mutator_keys.reverse.inject(REGISTRY[mutator_key].new) do |next_instance, next_key| 
          REGISTRY[next_key].new(next_instance)
        end
      end
    end
  end
end

require "#{Wrest::Root}/wrest/components/mutators/base"
require "#{Wrest::Root}/wrest/components/mutators/xml_simple_type_caster"
require "#{Wrest::Root}/wrest/components/mutators/xml_mini_type_caster"
require "#{Wrest::Root}/wrest/components/mutators/camel_to_snake_case"