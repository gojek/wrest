# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

RSpec.describe Wrest::CoreExt::String::Conversions do
  describe 'to_uri' do
    it 'knows how to convert a string to a Wrest::Uri' do
      expect('http://localhost:3000'.to_uri).to eq(Wrest::Uri.new('http://localhost:3000'))
    end

    it 'accepts username and password as options' do
      uri = 'http://localhost:3000'.to_uri(
        username: 'ooga',
        password: 'booga'
      )
      expect(uri.username).to eq('ooga')
      expect(uri.password).to eq('booga')
    end

    it 'strips leading spaces from a uri before building it' do
      expect(' http://localhost:3000'.to_uri).to eq(Wrest::Uri.new('http://localhost:3000'))
    end

    it 'strips trailing spaces from a uri before building it' do
      expect('http://localhost:3000  '.to_uri).to eq(Wrest::Uri.new('http://localhost:3000'))
    end

    it 'leaves the original string unchanged after building a uri from it' do
      url = ' http://localhost:3000  '
      expect(url.to_uri).to eq(Wrest::Uri.new('http://localhost:3000'))
      expect(url).to eq(' http://localhost:3000  ')
    end
  end

  describe 'to_uri_template' do
    it 'knows how to convert a string to a Wrest::UriTemplate' do
      expect('http://localhost:3000/:id'.to_uri_template).to eq(Wrest::UriTemplate.new('http://localhost:3000/:id'))
    end

    it 'strips leading spaces from a string before building it' do
      expect(' http://localhost:3000/:id'.to_uri_template).to eq(Wrest::UriTemplate.new('http://localhost:3000/:id'))
    end

    it 'strips trailing spaces from a string before building it' do
      expect('http://localhost:3000/:id  '.to_uri_template).to eq(Wrest::UriTemplate.new('http://localhost:3000/:id'))
    end

    it 'leaves the original string unchanged after building a uri from it' do
      url = ' http://localhost:3000/:id  '
      expect(url.to_uri_template).to eq(Wrest::UriTemplate.new('http://localhost:3000/:id'))
      expect(url).to eq(' http://localhost:3000/:id  ')
    end
  end
end
