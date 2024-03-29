# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

module Wrest
  module Components
    describe Mutators do
      it 'knows how to chain mutators without having to namespace them all' do
        mutator = described_class.chain(:xml_type_caster, :camel_to_snake_case)
        expect(mutator.class).to eq(Mutators::XmlTypeCaster)
        expect(mutator.next_mutator.class).to eq(Mutators::CamelToSnakeCase)
      end
    end
  end
end
