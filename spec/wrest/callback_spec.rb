# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wrest::Callback do
  let(:response200) { double(Net::HTTPOK, code: 200, message: 'OK', body: '', to_hash: {}) }

  context 'new' do
    context 'ensure_values_are_collections' do
      it 'returns a hash whose values are collections given a hash with values that are not collections' do
        hash = { 200 => ->(response) {} }
        hash = described_class.new(hash).callback_hash
        expect(hash[200]).to be_an_instance_of(Array)
      end

      it 'returns the hash unchanged if the given hash has values that are collections' do
        hash = { 200 => [->(response) {}] }
        expect(described_class.new(hash).callback_hash).to eq(hash)
      end
    end

    it 'creates a new Callback instance with copy of callback_hash given a Callback instance' do
      hash = { 200 => [->(response) {}] }
      callback = described_class.new hash
      expect(described_class.new(callback).callback_hash).to eq(hash)
    end

    it 'creates a new Callback instance with callback_hash as a key/value pair of HTTP code and collection of lambdas given a block' do
      block = lambda do |callback|
        callback.on_ok { |response| }
      end
      expect(described_class.new(block).callback_hash).to have(1).callbacks_for(200)
    end

    it 'creates a new Callback instance with empty callback_hash given an empty block' do
      block = ->(callback) {}
      expect(described_class.new(block).callback_hash).to be_empty
    end
  end

  context 'execute' do
    it 'executes all callbacks registered for HTTP code 200 given a response with the same code' do
      on_ok = false
      on_another_ok = false

      hash = { 200 => ->(_response) { on_ok = true } }
      block = lambda do |callback|
        callback.on_ok { |_response| on_another_ok = true }
      end
      uri_callback = described_class.new(hash)
      request_callback = described_class.new(block)
      callback = uri_callback.merge(request_callback)
      callback.execute(response200)
      expect(on_ok).to be_truthy
      expect(on_another_ok).to be_truthy
    end
  end

  context 'merge' do
    it 'returns a new Callback instance that has callbacks hash from both Callback instances' do
      callback1 = described_class.new({ 200 => ->(response) {} })
      block = lambda do |callback|
        callback.on_ok { |response| }
      end
      callback2 = described_class.new(block)
      merged_callback = callback1.merge(callback2)

      expect(merged_callback.callback_hash).to have(2).callbacks_for(200)
    end
  end

  context 'on_ok' do
    it 'registers a callback on HTTP 200 with the given block' do
      callback = described_class.new({})
      callback.on_ok { |response| }
      expect(callback.callback_hash).to have(1).callbacks_for(200)
    end

    it 'registers additional callback if a callback for HTTP 200 already exists with the given block' do
      callback = described_class.new(200 => ->(response) {})
      callback.on_ok { |response| }
      expect(callback.callback_hash).to have(2).callbacks_for(200)
    end

    it 'does not have any effect if called without a block' do
      on_ok = false
      callback = described_class.new({})
      callback.on_ok
      callback.execute(response200)
      expect(on_ok).to be_falsey
    end
  end

  context 'custom codes' do
    let(:code) { 200 }

    it 'registers a callback given a code as integer' do
      callback = described_class.new({})
      callback.on(code) { |response| }
      expect(callback.callback_hash).to have(1).callbacks_for(200)
    end

    it 'registers another callback given a code as integer is already registered' do
      callback = described_class.new(code => ->(response) {})
      callback.on(code) { |response| }
      expect(callback.callback_hash).to have(2).callbacks_for(200)
    end

    it 'registers a callback given a code as range' do
      code = 200..206
      callback = described_class.new({})
      callback.on(code) { |response| }
      expect(callback.callback_hash).to have(1).callbacks_for(200..206)
    end

    it 'registers another callback given a code as range is already registered' do
      code = 200..206
      callback = described_class.new(code => ->(response) {})
      callback.on(code) { |response| }
      expect(callback.callback_hash).to have(2).callbacks_for(200..206)
    end

    it 'executes a callback registered for a range of response codes given a response with code that falls in the range' do
      on_ok = false
      code = 200..206
      callback = described_class.new({})
      callback.on(code) { |_response| on_ok = true }
      callback.execute(response200)
      expect(on_ok).to be_truthy
    end

    it 'does not execute a callback registered for a range of response codes given a reponse with code that does not fall in the range' do
      block_executed = false
      code = 200..206
      callback = described_class.new(code => ->(_response) { block_executed = true })
      response301 = double(Net::HTTPOK, code: 301, message: 'moved permanenlty', body: '', to_hash: {})
      callback.execute(response301)
      expect(block_executed).to be_falsey
    end
  end
end
