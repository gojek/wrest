# frozen_string_literal: true

require 'spec_helper'
require 'rspec'

describe Wrest::Native::Get do
  let(:cache) { {} }
  let(:request_uri) { 'http://localhost/foo'.to_uri }
  let(:get_request) { described_class.new(request_uri, {}, {}, { cache_store: cache }) }

  context 'hashing and equality' do
    it 'is equal to itself' do
      expect(get_request).to eq(get_request) # rubocop:disable RSpec/IdenticalEqualityAssertion
    end

    it 'is equal to its clone' do
      expect(get_request).to eq(get_request.clone)
      expect(get_request.hash).to eq(get_request.clone.hash)
    end

    it 'is equal to a similar get but with different options' do
      # Use a different cache store, but it should not be considered when checking equality.
      another_get_with_same_properties = described_class.new(request_uri, {}, {}, { cache_store: cache.clone })

      expect(get_request).to eq(another_get_with_same_properties)
      expect(get_request.hash).to eq(another_get_with_same_properties.hash)
    end

    it 'is not equal to a get with different parameters even with same url' do
      another_get_with_extra_parameter = described_class.new(request_uri, { a_parameter: 10 }, {},
                                                             { cache_store: cache })
      expect(get_request).not_to eq(another_get_with_extra_parameter)
      expect(get_request.hash).not_to eq(another_get_with_extra_parameter.hash)
    end
  end

  it 'has a uri string with scheme and authority if no path and query params are specified' do
    get_request = described_class.new('http://localhost:3000'.to_uri, {}, {}, {})
    expect(get_request.full_uri_string).to eq('http://localhost:3000')
  end

  it 'has a uri string with scheme, username password and authority if no path and query params are specified' do
    uri = 'http://foo:bar@localhost:3000'.to_uri
    get_request = described_class.new(uri, {}, {}, {})
    expect(get_request.full_uri_string).to eq('http://foo:bar@localhost:3000')
  end

  it 'has a uri string with scheme, authority and path if no query params are specified' do
    uri = 'http://localhost:3000/articles/1/comments'.to_uri
    get_request = described_class.new(uri, {}, {}, {})
    expect(get_request.full_uri_string).to eq('http://localhost:3000/articles/1/comments')
  end

  it 'has a uri string with scheme, authority, path and query params when all are specified' do
    uri = 'http://localhost:3000/articles/1/comments'.to_uri
    get_request = described_class.new(uri, { title: 'this', author: 'that' }, {}, {})
    expect(get_request.full_uri_string).to eq('http://localhost:3000/articles/1/comments?author=that&title=this')
  end

  context 'build an identical request with caching disabled' do
    it 'calls Wrest::Get.new to build the new request' do
      expect(described_class).to receive(:new).with(get_request.uri, {}, {}, anything)
      get_request.build_request_without_cache_store({})
    end

    it "merges the validation headers with the new request's headers" do
      new_get = get_request.build_request_without_cache_store(foo: 'bar')
      expect(new_get.headers['foo']).to eq('bar')
    end

    it 'returns a similar get request with disable_cache and without cache store' do
      new_get = get_request.build_request_without_cache_store({})

      expect(new_get.parameters).to eq(get_request.parameters)
      expect(new_get.uri).to eq(get_request.uri)
      expect(new_get.options).to eq(get_request.options.merge(disable_cache: true).except(:cache_store))
    end
  end

  context 'caching' do
    after do
      Wrest::Caching.default_store = nil
    end

    it 'initializes CacheProxy' do
      expect(Wrest::CacheProxy).to receive(:new)
      get_request = described_class.new(request_uri, {}, {}, { cache_store: cache })
    end

    it 'calls the CacheProxy with nil cache store if disable_cache is passed' do
      expect(Wrest::CacheProxy).to receive(:new).with(anything, nil)

      Wrest::Caching.default_to_hash!
      get_request = described_class.new(request_uri, {}, {}, { disable_cache: true })
    end

    it 'routes all requests through cache proxy' do
      get_request = described_class.new(request_uri, {}, {}, { cache_store: cache })
      expect(get_request.cache_proxy).to receive(:get)
      get_request.invoke
    end
  end

  context 'functional', functional: true do
    let(:cache_store) { {} }
    let(:url) { 'http://localhost:3000'.to_uri(cache_store: cache_store) }

    describe 'cacheable responses' do
      it 'does not cache any non-cacheable response' do
        url['non_cacheable/nothing_explicitly_defined'].get
        url['non_cacheable/non_cacheable_statuscode'].get
        url['non_cacheable/no_store'].get
        url['non_cacheable/no_cache'].get
        url['non_cacheable/with_etag'].get

        expect(cache_store).to be_empty
      end

      it 'caches cacheable but cant_be_validated response' do
        # The server returns a different body for the same url on every call. So if the copy is cached by the client,
        # they should be equal.
        # rubocop:disable RSpec/IdenticalEqualityAssertion
        expect(url['cacheable/cant_be_validated/with_expires/300'].get).to eq(url['cacheable/cant_be_validated/with_expires/300'].get)
        expect(url['cacheable/cant_be_validated/with_max_age/300'].get).to eq(url['cacheable/cant_be_validated/with_max_age/300'].get)
        expect(url['cacheable/cant_be_validated/with_both_max_age_and_expires/300'].get).to eq(url['cacheable/cant_be_validated/with_both_max_age_and_expires/300'].get)
        # rubocop:enable RSpec/IdenticalEqualityAssertion
        expect(url['cacheable/cant_be_validated/with_both_max_age_and_expires/300'].get).not_to eq(url['cacheable/cant_be_validated/with_max_age/300'].get)
      end

      it 'gives the cached response itself when it has not expired' do
        initial_response = url['cacheable/cant_be_validated/with_expires/1'].get
        next_response = url['cacheable/cant_be_validated/with_expires/1'].get

        expect(next_response.body.split.first).to eq(initial_response.body.split.first)
      end

      it 'gives a new response after it has expired (for a non-validatable cache entry)' do
        initial_response = url['cacheable/cant_be_validated/with_expires/1'].get
        sleep 1
        next_response = url['cacheable/cant_be_validated/with_expires/1'].get

        expect(next_response.body.split.first).not_to eq(initial_response.body.split.first)
      end

      context 'validatable cache entry' do
        it 'gives the cached response itself if server gives a 304 (not modified)' do
          first_response_with_last_modified = url['/cacheable/can_be_validated/with_last_modified/always_304/1'].get
          first_response_with_etag = url['/cacheable/can_be_validated/with_etag/always_304/1'].get
          sleep 2
          second_response_with_last_modified = url['/cacheable/can_be_validated/with_last_modified/always_304/1'].get
          second_response_with_etag = url['/cacheable/can_be_validated/with_etag/always_304/1'].get

          expect(first_response_with_last_modified.body.split.first).to eq(second_response_with_last_modified.body.split.first)
          expect(first_response_with_etag.body.split.first).to eq(second_response_with_etag.body.split.first)
        end

        it 'updates the headers of an existing cache entry when the server sends a 304' do
          # RFC 2616
          # If a cache uses a received 304 response to update a cache entry, the cache MUST update the entry to reflect any new field values given in the response.
          Wrest::Caching.enable_memcached
          uri = 'http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_304/1'.to_uri(cache_store: Wrest::Caching::Memcached.new(
            nil, namespace: "wrest#{rand 1000}"
          ))

          first_response_with_last_modified = uri.get # Gets a 200 OK
          expect(first_response_with_last_modified.headers['Header-that-was-in-the-first-response']).to eq('42')
          expect(first_response_with_last_modified['header-that-changes-everytime']).to be_nil

          sleep 1

          # Cache expired. Wrest would send an If-Not-Modified, server will send 304 (Not Modified) with a header-that-changes-everytime
          second_response_with_last_modified = uri.get
          expect(second_response_with_last_modified.body).to eq(first_response_with_last_modified.body)
          expect(second_response_with_last_modified['header-that-changes-everytime'].to_i).to be > 0
          expect(second_response_with_last_modified.headers['Header-that-was-in-the-first-response']).to eq('42')

          a_new_get_request_to_same_resource = uri.get
          expect(a_new_get_request_to_same_resource.body).to eq(first_response_with_last_modified.body)
          expect(a_new_get_request_to_same_resource['header-that-changes-everytime'].to_i).to be > 0
          expect(a_new_get_request_to_same_resource['header-that-changes-everytime']).not_to eq(second_response_with_last_modified['header-that-changes-everytime'])
          expect(a_new_get_request_to_same_resource.headers['Header-that-was-in-the-first-response']).to eq('42')
        end

        it 'gives the new response if server sends a new one' do
          first_response_with_last_modified = url['/cacheable/can_be_validated/with_last_modified/always_give_fresh_response/1'].get
          first_response_with_etag = url['/cacheable/can_be_validated/with_etag/always_give_fresh_response/1'].get
          sleep 1
          second_response_with_last_modified = url['/cacheable/can_be_validated/with_last_modified/always_give_fresh_response/1'].get
          second_response_with_etag = url['/cacheable/can_be_validated/with_etag/always_give_fresh_response/1'].get

          expect(first_response_with_last_modified.body.split.first).not_to eq(second_response_with_last_modified.body.split.first)
          expect(first_response_with_etag.body.split.first).not_to eq(second_response_with_etag.body.split.first)
        end
      end
    end
  end
end
