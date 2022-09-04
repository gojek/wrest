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
    describe Mutators::XmlSimpleTypeCaster do
      before do
        @mutator = Mutators::XmlSimpleTypeCaster.new
      end

      # {"lead-bottle"=>[{"name"=>["Wooz"], "universe-id"=>[{"type"=>"integer", "nil"=>"true"}], "id"=>[{"type"=>"integer", "content"=>"1"}]}]}

      it 'typecasts a nil value in a tuple' do
        expect(@mutator.mutate(
                 ['universe-id', [{ 'type' => 'integer', 'nil' => 'true' }]]
               )).to eq(['universe-id', nil])
      end

      it 'leaves a string value in a tuple unchanged' do
        expect(@mutator.mutate(
                 ['name', ['Wooz']]
               )).to eq(%w[name Wooz])
      end

      it 'casts an integer value in a tuple' do
        expect(@mutator.mutate(
                 ['id', [{ 'type' => 'integer', 'content' => '1' }]]
               )).to eq(['id', 1])
      end

      it 'steps into a value if it is a hash' do
        expect(@mutator.mutate(
                 ['Result', [{
                   'PublishDate' => ['1240326000'],
                   'NewsSource' => [{ 'Online' => ['PC via News'],
                                      'UniqueId' => [{ 'type' => 'integer', 'content' => '1' }] }]
                 }]]
               )).to eq(['Result',
                         { 'PublishDate' => '1240326000',
                           'NewsSource' => { 'Online' => 'PC via News', 'UniqueId' => 1 } }])
      end
    end
  end
end
