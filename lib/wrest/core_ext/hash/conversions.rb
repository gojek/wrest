# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module CoreExt #:nodoc:
    module Hash #:nodoc:
      # Makes it easier to build other objects from a Hash
      module Conversions

        # This method accepts a hash mutator (found in Wrest::Compononents)
        # to build a new hash map by making changes to an existing one.
        #
        # No, this method does not mutate the state of the hash it is invoked on, 
        # but rather builds a new one.
        #
        # Yes, the name is misleading in that respect. However, one 
        # hopes the absence of an exclamation mark will increase clarity.
        #
        # Uses include mutating the hash produced by deserialising xml
        # by using the meta data in the hash to type cast values.
        # 
        # Example:
        # "http://search.yahooapis.com/NewsSearchService/V1/newsSearch".to_uri.get(
        #                           :appid  => 'YahooDemo', 
        #                           :output => 'xml',
        #                           :query  => 'India',
        #                           :results=> '3',
        #                           :start  => '1'
        #                         ).deserialise.mutate_using(XmlSimpleTypeCaster.new)
        def mutate_using(mutator)
          returning({})do |mutated_hash|
            self.each{|tuple| mutated_hash.store(*mutator.mutate(tuple))}
          end
        end
      end
    end
  end
end
