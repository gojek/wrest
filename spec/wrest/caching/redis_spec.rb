# frozen_string_literal: true

require 'spec_helper'

Wrest::Caching.enable_redis

RSpec.describe Wrest::Caching::Redis do
  context 'functional', functional: true do
    let(:redis) { described_class.new }

    context 'initialization defaults' do
      it 'alwayses default the options to an empty hash' do
        expect(Redis).to receive(:new).with({})
        client = described_class.new
      end

      it 'passes through options received to redis' do
        expect(Redis).to receive(:new).with(hash_including(host: '10.0.1.1', port: 6380, db: 15))
        client = described_class.new(host: '10.0.1.1', port: 6380, db: 15)
      end
    end

    it 'knows how to retrieve a cache entry' do
      request = 'http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_304/1000'
      ok_response = request.to_uri.get
      redis[request] = ok_response
      expect(redis[request]).to eq(ok_response)
    end

    it 'unmarshalls the value when retrieved a cache entry' do
      ok_response = 'http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_304/1000'.to_uri.get
      redis['example-123'] = ok_response

      expect(redis['example-123']).to eq(ok_response)
    end

    it 'sets expiry for the cache entry based on response headers' do
      uri_string = 'http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_give_fresh_response/10'
      ok_response = uri_string.to_uri.get
      redis[uri_string] = ok_response
      expect(redis.instance_eval('@redis', __FILE__, __LINE__).ttl(uri_string)).to eq(10)
    end

    it 'knows how to delete a cache entry' do
      request = 'http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_304/1000'
      ok_response = request.to_uri.get
      redis[request] = ok_response
      expect(redis.delete(request)).to eq(ok_response)
    end

    it 'returns nil on delete if the key is not present' do
      expect(redis.delete('not_present_key')).to be_nil
    end
  end
end
