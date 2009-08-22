# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Components
    # This is a base implementation of a
    # hash mutator that ensures that the <tt>mutate</tt> method
    # will chain to the next mutator by using a
    # template method.
    class Mutators::Base
      attr_reader :next_mutator

      # Registers all subclasses of Mutators::Base in
      # Mutators::REGISTRY making it easy to reference
      # and chain them later.
      #
      # See Mutators#chain for more information.
      def self.inherited(subklass)
        Wrest::Components::Mutators::REGISTRY[subklass.name.demodulize.underscore.to_sym] = subklass unless subklass.name.blank?
      end

      def initialize(next_mutator = nil)
        @next_mutator = next_mutator
      end

      # This is a template method which operates on a tuple (well, pair)
      # from a hash map and guarantees mutator chaining.
      #
      # Iterating over any hash using <tt>each</tt> injects
      # each key/value pair from the hash in the
      # form of an array.
      # This method expects of this form as an argument, i.e.
      # an array with the structure [:key, :value]
      #
      # The implementation of the mutation is achieved by
      # overriding the <tt>do_mutate</tt> method in a subclass.
      # Note that failing to do so will result in an exception
      # at runtime.
      def mutate(tuple)
        out_tuple = do_mutate(tuple)
        next_mutator ? next_mutator.mutate(out_tuple) : out_tuple
      end

      protected
      def do_mutate(tuple)
        raise Wrest::Exceptions::MethodNotOverridden
      end
    end
  end
end
