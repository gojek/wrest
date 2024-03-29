# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'
require 'wrest/components/mutators'

RSpec.describe Wrest::CoreExt::Hash::Conversions do
  it 'knows how to build a mutated hash given a hash mutator' do
    string_to_symbol_mutator_klass = Class.new(Wrest::Components::Mutators::Base)
    string_to_symbol_mutator_klass.class_eval do
      def mutate(pair)
        [pair.first.to_sym, pair.last]
      end
    end

    expect({ 'ooga' => 'booga' }.mutate_using(string_to_symbol_mutator_klass.new)).to eq({ ooga: 'booga' })
  end
end
