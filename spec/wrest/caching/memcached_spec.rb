# frozen_string_literal: true

require 'spec_helper'
require 'rspec'

Wrest::Caching.enable_memcached

describe Wrest::Caching do
  context 'functional', functional: true do
    before do
      @memcached = Wrest::Caching::Memcached.new
      @memcached['abc'] = 'xyz'
    end

    context 'initialization defaults' do
      it 'alwayses default the list of server urls to nil' do
        expect(Dalli::Client).to receive(:new).with(nil, {})
        client = Wrest::Caching::Memcached.new
      end

      it 'alwayses default the options to an empty hash' do
        expect(Dalli::Client).to receive(:new).with(nil, {})
        client = Wrest::Caching::Memcached.new
      end
    end

    it 'knows how to retrieve a cache entry' do
      expect(@memcached['abc']).to eq('xyz')
    end

    it 'knows how to update a cache entry' do
      @memcached['abc'] = '123'
      expect(@memcached['abc']).to eq('123')
    end

    it 'knows how to delete a cache entry' do
      expect(@memcached.delete('abc')).to eq('xyz')
      expect(@memcached['abc']).to be_nil
    end
  end
end
