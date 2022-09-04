# frozen_string_literal: true

require 'spec_helper'
require 'rspec'

describe Wrest::CacheProxy do
  let(:cache) { {} }
  let(:request_uri) { 'http://localhost/foo'.to_uri }
  let(:get_request) { Wrest::Native::Get.new(request_uri, {}, {}, { cache_store: cache }) }
  let(:ok_response) { Wrest::Native::Response.new(build_ok_response('', cacheable_headers)) }
  let(:cache_proxy) { get_request.cache_proxy }

  before do
    allow(get_request).to receive(:invoke_without_cache_check).and_return(ok_response)
  end

  context 'Factory' do
    it 'creates a Null cache proxy if cache store is nil' do
      expect(Wrest::CacheProxy::NullCacheProxy).to receive(:new)
      described_class.new(get_request, nil)
    end

    it 'creates a Default cache proxy class if cache store is available' do
      expect(Wrest::CacheProxy::DefaultCacheProxy).to receive(:new)
      described_class.new(get_request, {})
    end
  end

  context 'null caching' do
    it 'alwayses call invoke without cache check' do
      get_request = Wrest::Native::Get.new(request_uri, {}, {}, {})
      expect(get_request).to receive(:invoke_without_cache_check)

      cache_proxy = Wrest::CacheProxy::NullCacheProxy.new(get_request)
      cache_proxy.get
    end
  end

  context 'default caching' do
    it 'checks if response already exists in cache when making a request' do
      expect(cache).to receive(:[]).with(get_request.uri.to_s)
      cache_proxy.get
    end

    it 'gives a new response if it is not in the cache' do
      expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(nil)
      expect(cache_proxy.get).to eq(ok_response)
    end

    it 'caches the response after invoke makes a fresh request' do
      expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(nil)
      expect(get_request).to receive(:invoke_without_cache_check).and_return(ok_response)
      expect(cache_proxy).to receive(:cache).with(ok_response)
      cache_proxy.get
    end

    it 'does not call invoke_without_cache_check if response exists in cache' do
      expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(ok_response)
      expect(get_request).not_to receive(:invoke_without_cache_check)
      cache_proxy.get
    end

    it 'checks whether the cache entry has expired' do
      expect(cache).to receive(:[]).and_return(ok_response)
      expect(ok_response).to receive(:expired?)
      cache_proxy.get
    end

    it "uses the cached response if it finds a matching one that hasn't expired" do
      cached_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers.tap do |h|
        h['random'] = 123
      end))

      expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(cached_response)
      expect(cached_response).to receive(:expired?).and_return(false)

      expect(cache_proxy.get).to eq(cached_response)
    end

    it 'checks whether an expired cache entry can be validated' do
      expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(ok_response)

      expect(ok_response).to receive(:expired?).and_return(true)
      expect(ok_response).to receive(:can_be_validated?)

      cache_proxy.get
    end

    context 'Cache Validation' do
      context 'how to validate a cache entry' do
        let(:direct_get) { Wrest::Native::Get.new(request_uri) }
        let(:default_options_with_cache_disabled) do
          { follow_redirects: true, follow_redirects_count: 0,
            follow_redirects_limit: 5, disable_cache: true }
        end

        it 'builds a new identical Get with an If-Not-Modified if the cache has a Last-Modified' do
          expect(ok_response).to receive(:expired?).and_return(true)
          expect(ok_response.can_be_validated?).to be(true)

          expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(ok_response)
          expect(get_request).to receive(:build_request_without_cache_store).with(hash_including('if-modified-since' => ok_response.headers['last-modified'])).and_return(direct_get)
          expect(direct_get).to receive(:invoke).and_return(ok_response)

          cache_proxy.get
        end

        it 'sends an If-None-Match Get request if the cache has an ETag' do
          response_with_etag = Wrest::Native::Response.new(build_ok_response('', cacheable_headers.tap do |h|
            h.delete 'last-modified'
            h['etag'] = '123'
          end))

          expect(response_with_etag).to receive(:expired?).and_return(true)
          expect(response_with_etag.can_be_validated?).to be(true)

          expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(response_with_etag)

          expect(get_request).to receive(:build_request_without_cache_store).with(hash_including('if-none-match' => '123')).and_return(direct_get)
          expect(direct_get).to receive(:invoke).and_return(response_with_etag)

          cache_proxy.get
        end
      end

      context 'using a validation response' do
        let(:cached_response) do
          one_day_back = (Time.now - (60 * 60 * 24)).httpdate
          Wrest::Native::Response.new(build_ok_response('', cacheable_headers.tap do |h|
            h['random'] = 235
            h['expires'] = one_day_back
          end))
        end

        # 304 is Not Modified
        it 'uses the cached response if the server returns 304' do
          not_modified_response = ok_response.clone
          expect(not_modified_response).to receive(:code).at_least(:once).and_return('304')
          expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(cached_response)

          expect(cache_proxy).to receive(:send_validation_request_for).and_return(not_modified_response)

          # only check the body, can't compare the entire object - the headers from 304 would be merged with the cached response's headers.
          expect(cache_proxy.get.body).to eq(cached_response.body)
        end

        context 'update headers of a cached response with headers from a 304' do
          # RFC 2616 13.5.3 Combining Headers

          it 'calls update_cache_headers' do
            not_modified_response = ok_response.clone
            expect(not_modified_response).to receive(:code).at_least(:once).and_return('304')
            expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(cached_response)

            expect(cache_proxy).to receive(:send_validation_request_for).and_return(not_modified_response)
            expect(cache_proxy).to receive(:update_cache_headers_for).with(cached_response, not_modified_response)

            cache_proxy.get
          end

          context 'update_cache_headers' do
            it 'updates End-To-End headers' do
              one_day_back = (Time.now - (60 * 60 * 24)).httpdate
              tomorrow = (Time.now + (60 * 60 * 24)).httpdate

              cached_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers.tap do |h|
                h['expires'] = one_day_back
              end))
              not_modified_response = Wrest::Native::Response.new(build_response('304', 'Not Modified', '', cacheable_headers.tap do |h|
                h['expires'] = tomorrow
              end))

              expect(cached_response['expires']).to eq(one_day_back)

              cache_proxy.update_cache_headers_for(cached_response, not_modified_response)

              expect(cached_response['expires']).to eq(tomorrow)
            end

            it 'does not update Hop-By-Hop headers' do
              cached_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers.tap do |h|
                h['trailers'] = 'foo'
              end))
              not_modified_response = Wrest::Native::Response.new(build_response('304', 'Not Modified', '', cacheable_headers.tap do |h|
                h['trailers'] = 'bar'
              end))

              expect(cached_response['trailers']).to eq('foo')
              cache_proxy.update_cache_headers_for(cached_response, not_modified_response)
              expect(cached_response['trailers']).to eq('foo')
            end
          end
        end

        it 'uses it if the server returns a new response' do
          new_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers))
          expect(new_response).to receive(:code).at_least(:once).and_return('200')

          expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(cached_response)
          expect(cache_proxy).to receive(:send_validation_request_for).and_return(new_response)

          expect(cache_proxy.get).to eq(new_response)
        end

        it 'alsoes cache it when the server returns a new response' do
          new_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers))
          expect(new_response).to receive(:code).at_least(:once).and_return('200')

          expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(cached_response)
          expect(cache_proxy).to receive(:send_validation_request_for).and_return(new_response)
          expect(cache).to receive(:[]=).once

          expect(cache_proxy.get).to eq(new_response)
        end
      end
    end
  end

  context 'conditions governing caching' do
    it 'tries to cache a response if was not already cached' do
      expect(get_request).to receive(:invoke_without_cache_check).and_return(ok_response)
      expect(cache_proxy).to receive(:cache).with(ok_response)
      cache_proxy.get
    end

    it 'checks whether a response is cacheable when trying to cache a response' do
      expect(cache).to receive(:[]).with(get_request.uri.to_s).and_return(nil)
      expect(get_request).to receive(:invoke_without_cache_check).and_return(ok_response)
      expect(ok_response).to receive(:cacheable?).and_return(false)
      cache_proxy.get
    end

    it 'stores response in cache if response is cacheable' do
      response = ok_response
      expect(response.cacheable?).to be(true)
      expect(get_request).to receive(:invoke_without_cache_check).and_return(response)
      expect(cache).to receive(:[]=).with(get_request.uri.to_s, response)
      cache_proxy.get
    end
  end

  describe 'redis specific caching', functional: true do
    before :all do
      Wrest::Caching.enable_redis
    end

    let(:request_uri) { 'http://localhost:3000/query_based_response'.to_uri }
    let(:query_params_one) { { name: 'Example', age: 21 } }
    let(:query_params_two) { { height: 174, units: 'cm' } }
    let(:redis_cache) { Wrest::Caching::Redis.new }
    let(:get_request_one) { Wrest::Native::Get.new(request_uri, query_params_one, {}, { cache_store: redis_cache }) }
    let(:get_request_two) { Wrest::Native::Get.new(request_uri, query_params_two, {}, { cache_store: redis_cache }) }

    after do
      redis_cache.delete(get_request_one)
      redis_cache.delete(get_request_two)
    end

    it 'has different responses for get request with same scheme, authority, paths but different query params, given that response changes with query params' do
      cache_proxy_one = described_class.new(get_request_one, redis_cache)
      cache_proxy_two = described_class.new(get_request_two, redis_cache)
      expect(cache_proxy_one.get).not_to eq(cache_proxy_two.get)
    end
  end
end
