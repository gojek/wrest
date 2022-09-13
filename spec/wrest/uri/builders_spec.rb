# frozen_string_literal: true

require 'spec_helper'

describe Wrest::Uri::Builders do
  let(:uri) { 'http://localhost:3000'.to_uri }

  context 'using_threads' do
    it 'returns a new uri' do
      threaded_uri = uri.using_threads
      expect(uri).not_to equal(threaded_uri)
    end

    it 'has the thread backend in options hash' do
      uri = 'http://localhost:3000/no_body'.to_uri
      threaded_uri = uri.using_threads
      expect(threaded_uri.instance_variable_get('@options')[:asynchronous_backend]).to be_an_instance_of(Wrest::AsyncRequest::ThreadBackend)
    end
  end

  context 'using_em' do
    before(:all) { Wrest::AsyncRequest.enable_em }

    it 'returns a new uri' do
      evented_uri = uri.using_em
      expect(uri).not_to equal(evented_uri)
    end

    it 'has the eventmachine backend in options hash' do
      evented_uri = uri.using_em
      expect(evented_uri.instance_variable_get('@options')[:asynchronous_backend]).to be_a(Wrest::AsyncRequest::EventMachineBackend)
    end
  end

  context 'using_hash' do
    it 'returns a new uri' do
      cache_enabled_uri = uri.using_hash
      expect(uri).not_to equal(cache_enabled_uri)
    end

    it 'sets a hash as cache store in options hash' do
      cache_enabled_uri = uri.using_hash
      expect(cache_enabled_uri.instance_variable_get('@options')[:cache_store]).to be_an_instance_of(Hash)
    end
  end

  context 'using_memcached' do
    before(:all) { Wrest::Caching.enable_memcached }

    it 'returns a new uri' do
      cache_enabled_uri = uri.using_memcached
      expect(uri).not_to equal(cache_enabled_uri)
    end

    it 'sets memcached as cache store in options hash' do
      cache_enabled_uri = uri.using_memcached
      expect(cache_enabled_uri.instance_variable_get('@options')[:cache_store]).to be_an_instance_of(Wrest::Caching::Memcached)
    end
  end

  context 'using_redis' do
    before(:all) { Wrest::Caching.enable_redis }

    it 'returns a new uri' do
      cache_enabled_uri = uri.using_redis
      expect(uri).to eq(cache_enabled_uri)
    end

    it 'sets redis as cache store in options hash' do
      cache_enabled_uri = uri.using_redis
      expect(cache_enabled_uri.instance_variable_get('@options')[:cache_store]).to be_a(Wrest::Caching::Redis)
    end
  end

  context 'disable_cache' do
    it 'returns a new uri' do
      cache_disabled_uri = uri.disable_cache
      expect(uri).not_to equal(cache_disabled_uri)
    end

    it 'sets a flag indicating to disable cache on requests made through the uri' do
      cache_disabled_uri = uri.disable_cache
      expect(cache_disabled_uri.instance_variable_get('@options')[:disable_cache]).to be_truthy
    end
  end

  context 'using_cookie' do
    it 'builds a new Uri that has the cookie as a default' do
      cookied_uri = uri.using_cookie('some-encoded-cookie-string')
      expect(cookied_uri.default_headers).to eq(Wrest::H::Cookie => 'some-encoded-cookie-string')
    end
  end
end
