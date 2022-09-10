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

module Wrest
  module Components
    describe Mutators::Base do
      it 'raises an exception if mutate is invoked without do_mutate being implemented in a subclass' do
        expect { Class.new(described_class).new.mutate([]) }.to raise_error(Wrest::Exceptions::MethodNotOverridden)
      end

      it 'ensures that the next mutator is invoked for a subclass' do
        next_mutator = double('Mutator')
        mutator = Mutators::CamelToSnakeCase.new(next_mutator)

        expect(next_mutator).to receive(:mutate).with(['a', 1]).and_return([:a, '1'])

        expect(mutator.mutate(['a', 1])).to eq([:a, '1'])
      end

      it 'knows how to chain mutators recursively' do
        mutator = Mutators::XmlSimpleTypeCaster.new(Mutators::CamelToSnakeCase.new)
        expect(mutator.mutate(
                 ['Result', [{
                   'Publish-Date' => ['1240326000'],
                   'News-Source' => [{ 'Online' => ['PC via News'],
                                       'Unique-Id' => [{ 'type' => 'integer', 'content' => '1' }] }]
                 }]]
               )).to eq(['result',
                         { 'publish_date' => '1240326000',
                           'news_source' => { 'online' => 'PC via News', 'unique_id' => 1 } }])
      end

      it 'registers all subclasses in the registry' do
        class SomeMutator < Mutators::Base; end # rubocop:disable RSpec/LeakyConstantDeclaration
        expect(Mutators.registry[:some_mutator]).to eq(SomeMutator)
      end
    end
  end
end
