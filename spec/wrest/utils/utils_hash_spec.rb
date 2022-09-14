# frozen_string_literal: false

# Copyright 2009-2022 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

RSpec.describe Wrest::Utils, '.hash' do
  describe '#to_param' do
    it 'converts a hash to a url query string' do
      expect(
        described_class.hash_to_param(name: 'David', nationality: 'Danish')
      ).to eq('name=David&nationality=Danish')
    end
  end
end
