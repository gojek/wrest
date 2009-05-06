# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


module Wrest
  module Components
    # This mutator undertands how do type casting
    # using the type data embedded in a hash
    # created by deserialising an xml using
    # ActiveSupport::XmlMini
    class Mutators::XmlMiniTypeCaster < Mutators::Base
      def do_mutate(tuple)
        out_key, in_value = tuple

        case in_value
        when Hash
          if in_value['nil'] == 'true'
            out_value = nil
          elsif in_value.key?('type')
            caster = ActiveSupport::CoreExtensions::Hash::Conversions::XML_PARSING[in_value['type']]
            out_value = caster ? caster.call(in_value['__content__']) : in_value
          elsif in_value.key?('__content__')
            out_value = in_value['__content__']
          else
            out_value = in_value.mutate_using(self)
          end
        when Array
          out_value = in_value.collect{|hash| hash.mutate_using(self)}
        else
          out_value = in_value
        end

        [out_key, out_value]
      end
    end
  end
end
