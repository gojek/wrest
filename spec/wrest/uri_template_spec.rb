# frozen_string_literal: false

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

module Wrest
  describe Wrest::UriTemplate do
    it 'does not maintain a reference to the string it is initialized with' do
      url_pattern = 'http://localhost:3000/:resource/:id.:format'
      template = described_class.new(url_pattern)
      url_pattern.gsub!(':', '!')
      expect(template.uri_pattern).to eq('http://localhost:3000/:resource/:id.:format')
    end

    it 'knows how to build a Wrest::Uri from the pattern given a set of replacement options' do
      template = described_class.new('http://localhost:3000/:resource/:id.:format')
      expect(template.to_uri(
               resource: 'shen_coins', id: 5, format: :json
             )).to eq('http://localhost:3000/shen_coins/5.json'.to_uri)
    end

    it 'ensures uri built out of template receives options' do
      template = described_class.new('http://:user::password@coathangers.com/:resource/:id', {
                                       user: 'kaiwren',
                                       password: 'fupuppies',
                                       resource: 'portal',
                                       id: '1'
                                     })
      expect(template.to_uri).to eq('http://kaiwren:fupuppies@coathangers.com/portal/1'.to_uri)
    end

    it 'alsoes handle username and password' do
      template = described_class.new('http://:user::password@coathangers.com/:resource/:id')
      expect(template.to_uri(
               user: 'kaiwren',
               password: 'fupuppies',
               resource: 'portal',
               id: '1'
             )).to eq('http://kaiwren:fupuppies@coathangers.com/portal/1'.to_uri)
    end

    describe 'equals' do
      it 'has the same uri_pattern' do
        expect(described_class.new('http://localhost:3000/:resource/:id.:format')).not_to eq(described_class.new('http://localhost:3000/:id/:resource.:format'))
        # rubocop:disable RSpec/IdenticalEqualityAssertion
        expect(described_class.new('http://localhost:3000/:resource/:id.:format')).to eq(described_class.new('http://localhost:3000/:resource/:id.:format'))
        # rubocop:enable RSpec/IdenticalEqualityAssertion
      end
    end

    context 'extension' do
      it 'knows how to build a new UriTemplate from an existing one by appending a path' do
        expect(described_class.new('http://localhost:3000')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
      end

      it 'knows how to extend a UriTemplate that already has a path' do
        expect(described_class.new('http://localhost:3000/1')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/1/ooga/booga'))
        expect(described_class.new('http://localhost:3000/1')['ooga/booga']).to eq(described_class.new('http://localhost:3000/1/ooga/booga'))
        expect(described_class.new('http://localhost:3000/1/')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/1/ooga/booga'))

        expect(described_class.new('http://localhost:3000/1')[':ooga/booga']).to eq(described_class.new('http://localhost:3000/1/:ooga/booga'))
        expect(described_class.new('http://localhost:3000/1')[':ooga/booga']).to eq(described_class.new('http://localhost:3000/1/:ooga/booga'))
        expect(described_class.new('http://localhost:3000/1/')[':ooga/booga']).to eq(described_class.new('http://localhost:3000/1/:ooga/booga'))
      end

      it 'handles / positions with wisdom' do
        expect(described_class.new('http://localhost:3000/')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
        expect(described_class.new('http://localhost:3000')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
        expect(described_class.new('http://localhost:3000/')['ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
        expect(described_class.new('http://localhost:3000')['ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
      end
    end
  end
end
