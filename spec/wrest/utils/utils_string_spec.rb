# frozen_string_literal: false

# Copyright 2009-2022 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

RSpec.describe Wrest::Utils, '.string' do
  describe '#string_blank?' do
    it 'knows an empty string is blank' do
      expect(described_class).to be_a_string_blank('')
    end

    it 'knows an string with spaces is blank' do
      expect(described_class).to be_a_string_blank("\n ")
    end

    it 'knows an string with chars is not blank' do
      expect(described_class).not_to be_a_string_blank('not blank')
    end
  end

  describe '#string_constantize' do
    it 'constantizes a string' do
      expect(described_class.string_constantize('Wrest::Utils')).to eq(described_class)
    end
  end

  describe '#string_demodulize' do
    it 'converts ActiveSupport::Inflector::Inflections to Inflections' do
      expect(described_class.string_demodulize('ActiveSupport::Inflector::Inflections')).to eq('Inflections')
    end

    it 'converts ::Inflections to Inflections' do
      expect(described_class.string_demodulize('::Inflections')).to eq('Inflections')
    end

    it 'does not change Inflections' do
      expect(described_class.string_demodulize('Inflections')).to eq('Inflections')
    end
  end

  describe '#string_underscore' do
    it 'converts ActiveModel to active_model' do
      expect(described_class.string_underscore('ActiveModel')).to eq('active_model')
    end

    it 'converts ActiveModel::Errors to active_model/errors' do
      expect(described_class.string_underscore('ActiveModel::Errors')).to eq('active_model/errors')
    end
  end
end
