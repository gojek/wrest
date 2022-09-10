# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wrest::Native::Response do
  context 'Aliased methods' do
    it 'has #deserialize delegate to #deserialise' do
      response = described_class.new(double('Response', code: '200'))

      expect(response).to receive(:deserialise)
      response.deserialize
    end

    it 'has #deserialize_using delegate to #deserialise_using' do
      response = described_class.new(double('Response', code: '200'))

      expect(response).to receive(:deserialise_using)
      response.deserialize_using
    end
  end

  describe 'hashing and comparison' do
    it '_should return true for equality between two identical Wrest::Response objects and their hashes' do
      http_response = build_ok_response
      response = described_class.new(http_response)

      expect(response).to eq(response.clone)
      expect(response.hash).to eq(response.clone.hash)

      identical_response = described_class.new(http_response)
      expect(response).to eq(identical_response)
      expect(response.hash).to eq(identical_response.hash)

      different_response = described_class.new(build_response('301'))

      expect(response).not_to eq(different_response)
      expect(response.hash).not_to eq(different_response.hash)
    end
  end

  it 'clones its headers whenever the response is cloned' do
    headers = { 'foo' => 'original' }
    http_response = double(Net::HTTPResponse, code: '200', to_hash: headers)

    response = described_class.new(http_response)
    expect(response.headers['foo']).to eq('original')

    new_response = response.clone
    expect(new_response.headers['foo']).to eq('original')

    new_response.headers['foo'] = 'new'
    expect(new_response.headers['foo']).to eq('new')

    expect(response.headers['foo']).to eq('original')
  end

  it 'builds a Redirection instead of a normal response if the code is 301..303 or 305..3xx' do
    http_response = double(Net::HTTPRedirection)
    allow(http_response).to receive(:code).and_return('301')

    expect(described_class.new(http_response).class).to eq(Wrest::Native::Redirection)
  end

  it 'builds a normal response if the code is 304' do
    http_response = double(Net::HTTPRedirection)
    allow(http_response).to receive(:code).and_return('304')

    expect(described_class.new(http_response).class).to eq(described_class)
  end

  it 'builds a normal Response for non 3xx codes' do
    http_response = double(Net::HTTPResponse)
    allow(http_response).to receive(:code).and_return('200')

    expect(described_class.new(http_response).class).to eq(described_class)
  end

  it 'knows how to delegate to a translator' do
    http_response = double('response')
    allow(http_response).to receive(:code).and_return('200')
    expect(Wrest::Components::Translators::Xml).to receive(:deserialise).with(http_response, {})
    described_class.new(http_response).deserialise_using(Wrest::Components::Translators::Xml)
  end

  it 'knows how to load a translator based on content type' do
    http_response = double('response')
    allow(http_response).to receive(:code).and_return('422')
    expect(http_response).to receive(:content_type).and_return('application/xml')

    response = described_class.new(http_response)
    expect(response).to receive(:deserialise_using).with(Wrest::Components::Translators::Xml, {})

    response.deserialise
  end

  it 'knows how to deserialise a json response' do
    http_response = double('response')
    allow(http_response).to receive(:code).and_return('200')
    expect(http_response).to receive(:body).and_return("{ \"menu\": \"File\",
      \"commands\": [ { \"title\": \"New\", \"action\":\"CreateDoc\" }, {
      \"title\": \"Open\", \"action\": \"OpenDoc\" }, { \"title\": \"Close\",
      \"action\": \"CloseDoc\" } ] }")
    expect(http_response).to receive(:content_type).and_return('application/json')

    response = described_class.new(http_response)

    expect(response.deserialise).to eq({ 'commands' => [{ 'title' => 'New',
                                                          'action' => 'CreateDoc' },
                                                        { 'title' => 'Open', 'action' => 'OpenDoc' }, { 'title' => 'Close',
                                                                                                        'action' => 'CloseDoc' }], 'menu' => 'File' })
  end

  it 'simplies return itself when asked to follow (null object behaviour - see MovedPermanently for more context)' do
    http_response = double('response')
    allow(http_response).to receive(:code).and_return('422')

    response = described_class.new(http_response)
    expect(response.follow).to be_equal(response)
  end

  describe 'Keep-Alive' do
    it 'knows when a connection has been closed' do
      http_response = build_ok_response
      response = described_class.new(http_response)

      expect(response).to receive(:[]).with(Wrest::H::Connection).and_return('Close')
      expect(response).to be_connection_closed
    end

    it 'knows when a keep-alive connection has been established' do
      http_response = build_ok_response
      response = described_class.new(http_response)

      expect(response).to receive(:[]).with(Wrest::H::Connection).and_return('')
      expect(response).not_to be_connection_closed
    end
  end

  context 'caching' do
    context 'cases where response should be cached' do
      it 'says its cacheable if the response code is cacheable' do
        # the cacheable codes are enumerated in Firefox source code: nsHttpResponseHead.cpp::MustValidate
        http_response = build_ok_response('', cacheable_headers)
        %w[200 203 300 301].each do |code|
          allow(http_response).to receive(:code).and_return(code)
          response = described_class.new(http_response)
          expect(response).to be_cacheable
        end
      end

      it 'is cacheable for response with Expires header in future' do
        response = described_class.new(build_ok_response('', cacheable_headers))
        expect(response).to be_cacheable
      end

      context 'cache control headers' do
        it 'parses the cache-control header into an array' do
          http_response = described_class.new(build_ok_response('',
                                                                cacheable_headers.merge('Cache-Control' => 'abc,test=100,max-age=20')))
          expect(http_response.cache_control_headers).to eq(['abc', 'test=100', 'max-age=20'])
        end

        it 'parses the cache-control header when it has leading and trailing spaces' do
          http_response = described_class.new(build_ok_response('',
                                                                cacheable_headers.merge('Cache-Control' => '  abc, test=100 , max-age=20 ')))
          expect(http_response.cache_control_headers).to eq(['abc', 'test=100', 'max-age=20'])
        end

        it 'caches the result of the Cache-Control header parse' do
          http_response = described_class.new(build_ok_response('',
                                                                cacheable_headers.merge('Cache-Control' => 'xyz')))
          expect(http_response).to receive(:recalculate_cache_control_headers).once.and_return(['xyz'])

          http_response.cache_control_headers
          expect(http_response.cache_control_headers).to eq(['xyz'])
        end
      end

      it 'is cacheable for response with max-age still not expired' do
        cache_control_headers = cacheable_headers.merge('cache-control' => "max-age=#{10 * 30}")
                                                 .tap { |h| h.delete('expires') }
        ok_response = build_ok_response('', cache_control_headers)
        response = described_class.new(ok_response) # 30mins max-age
        expect(response).to be_cacheable
      end
    end

    context 'cases where response should not be cached' do
      it 'says its not cacheable if the response code is not range of 200-299' do
        http_response = build_ok_response('', cacheable_headers)
        %w[100 206 400 401 500].each do |code|
          allow(http_response).to receive(:code).and_return(code)
          response = described_class.new(http_response)
          expect(response.cacheable?).to be(false)
        end
      end

      it 'is not cacheable for responses with neither Expires nor Max-Age' do
        response = described_class.new(build_ok_response)
        expect(response.cacheable?).to be(false)
      end

      it 'is not cacheable for responses with invalid Expires or Date values' do
        response = described_class.new(build_ok_response('', cacheable_headers.merge('expires' => ['invalid date'])))
        expect(response.cacheable?).to be(false)

        response = described_class.new(build_ok_response('', cacheable_headers.merge('date' => ['invalid date'])))
        expect(response.cacheable?).to be(false)
      end

      it 'is not cacheable for responses with cache-control header no-cache' do
        response = described_class.new(build_ok_response('', 'cache-control' => ['no-cache']))
        expect(response.cacheable?).to be(false)
      end

      it 'is not cacheable for responses with cache-control header no-store' do
        response = described_class.new(build_ok_response('', 'cache-control' => ['no-store']))
        expect(response.cacheable?).to be(false)
      end

      it 'is not cacheable for responses with header pragma no-cache' do
        response = described_class.new(build_ok_response('', cacheable_headers.merge('pragma' => ['no-cache']))) # HTTP 1.0
        expect(response.cacheable?).to be(false)
      end

      it 'is not cacheable for response with Expires header in past' do
        ten_mins_early = (Time.now - (10 * 30)).httpdate

        response = described_class.new(build_ok_response('', cacheable_headers.merge('expires' => [ten_mins_early])))
        expect(response.cacheable?).to be(false)
      end

      it 'is not cacheable for response without a max-age, and its Expires is already less than its Date' do
        one_day_before = (Time.now - (24 * 60 * 60)).httpdate
        response = described_class.new(build_ok_response('', cacheable_headers.merge('expires' => [one_day_before])))
        expect(response.cacheable?).to be(false)
      end

      it 'is cacheable if vary header is set' do
        response = described_class.new(build_ok_response('', cacheable_headers.merge('vary' => 'Accept-Encoding')))
        expect(response.cacheable?).to be(true)
      end

      it 'is not cacheable if vary header is *' do
        response = described_class.new(build_ok_response('', cacheable_headers.merge('vary' => '*')))
        expect(response.cacheable?).to be(false)
      end
    end

    describe 'page validity and expiry' do
      let(:headers) { cacheable_headers }

      it 'returns correct values for code_cacheable?' do
        http_response = build_ok_response('', cacheable_headers)
        allow(http_response).to receive(:code).and_return('300')
        expect(described_class.new(http_response).code_cacheable?).to be(true)

        allow(http_response).to receive(:code).and_return('500')
        expect(described_class.new(http_response).code_cacheable?).to be(false)
      end

      it 'returns correct values for max_age' do
        http_response = build_ok_response
        expect(described_class.new(http_response).max_age).to be_nil

        http_response = build_ok_response('', cacheable_headers.merge('cache-control' => 'public=200, max-age=30'))
        expect(described_class.new(http_response).max_age).to eq(30)
      end

      it 'returns correct values for no_cache_flag_not_set?' do
        http_response = build_ok_response
        expect(described_class.new(http_response).no_cache_flag_not_set?).to be(true)

        http_response = build_ok_response('', cacheable_headers.merge('cache-control' => ' abcd, no-cache '))
        expect(described_class.new(http_response).no_cache_flag_not_set?).to be(false)
      end

      it 'returns correct values for no_store_flag_not_set?' do
        http_response = build_ok_response
        expect(described_class.new(http_response).no_store_flag_not_set?).to be(true)

        http_response = build_ok_response('', cacheable_headers.merge('cache-control' => 'no-store'))
        expect(described_class.new(http_response).no_store_flag_not_set?).to be(false)
      end

      it 'returns correct values for pragma_nocache_not_set?' do
        http_response = build_ok_response
        expect(described_class.new(http_response).pragma_nocache_not_set?).to be(true)

        http_response = build_ok_response('', cacheable_headers.merge('pragma' => 'no-cache '))
        expect(described_class.new(http_response).pragma_nocache_not_set?).to be(false)
      end

      it 'returns correct values for response_date' do
        headers = cacheable_headers

        http_response = build_ok_response('', cacheable_headers)
        expect(described_class.new(http_response).response_date).to eq(DateTime.parse(headers['date']))

        http_response = build_ok_response('', cacheable_headers.merge('date' => 'INVALID DATE'))
        expect(described_class.new(http_response).response_date).to be_nil
      end

      it 'returns correct values for expires' do
        headers = cacheable_headers

        http_response = build_ok_response('', cacheable_headers)
        expect(described_class.new(http_response).expires).to eq(DateTime.parse(headers['expires']))

        http_response = build_ok_response('', cacheable_headers.merge('expires' => 'INVALID DATE'))
        expect(described_class.new(http_response).expires).to be_nil
      end

      it 'returns correct values for current_age' do
        headers['date'] = (Time.now - (10 * 60)).httpdate
        response = described_class.new(build_ok_response('', headers))
        expect((response.current_age - (10 * 60)).abs.to_i).to eq(0)

        headers['age'] = (100 * 60).to_s # 100 minutes : Age is larger than Time.now-Expires
        response = described_class.new(build_ok_response('', headers))
        expect((response.current_age - (100 * 60)).abs.to_i).to eq(0)
      end

      context 'freshness lifetime' do
        it 'caches the calculated freshness_lifetime' do
          response = described_class.new(build_ok_response('', headers))

          expect(response).to receive(:recalculate_freshness_lifetime).once.and_return(100)

          response.freshness_lifetime
          expect(response.freshness_lifetime).to eq(100)
        end

        it 'calculates freshness_lifetime for response with an Expiry header' do
          response = described_class.new(build_ok_response('', headers))
          expect(response.recalculate_freshness_lifetime).to eq(30 * 60)
        end

        it 'calculates freshness_lifetime for response with a Cache-Control: max-age header' do
          headers['cache-control'] = 'max-age=600'
          response = described_class.new(build_ok_response('', headers))
          expect(response.recalculate_freshness_lifetime).to eq(600) # max-age takes priority over Expires
        end
      end

      it 'correctlies say whether a response has its Expires in its past' do
        headers['expires'] = (Time.now - (5 * 60)).httpdate
        response = described_class.new(build_ok_response('', headers))
        expect(response.expires_not_in_its_past?).to be(false)

        headers['expires'] = (Time.now + (5 * 60)).httpdate
        response = described_class.new(build_ok_response('', headers))
        expect(response.expires_not_in_its_past?).to be(true)
      end

      it 'correctlies say whether a response has its Expires in our past' do
        headers['expires'] = (Time.now - (24 * 60 * 60)).httpdate
        response = described_class.new(build_ok_response('', headers))
        expect(response.expires_not_in_our_past?).to be(false)

        headers['expires'] = (Time.now + (24 * 60 * 60)).httpdate
        response = described_class.new(build_ok_response('', headers))
        expect(response.expires_not_in_our_past?).to be(true)
      end

      it 'says not expired for requests with Expires in the future' do
        response = described_class.new(build_ok_response('', headers))
        expect(response.expired?).to be(false)
      end

      it 'says expired for requests with Expires in the past' do
        time_in_past = (Time.now - (10 * 60)).httpdate
        headers['expires'] = time_in_past
        response = described_class.new(build_ok_response('', headers))
        expect(response.expired?).to be(true)
      end

      it 'says expired for requests that have lived past its max-age' do
        headers.delete 'Expires'
        headers['cache-control'] = 'max-age=0'
        response = described_class.new(build_ok_response('', headers))
        expect(response.expired?).to be(true)
      end

      it "says not expired for requests that haven't reached max-age" do
        headers['cache-control'] = 'max-age=60000'
        response = described_class.new(build_ok_response('', headers))
        expect(response.expired?).to be(false)
      end

      describe 'when can a response be validated by sending If-Not-Modified or If-None-Match' do
        it 'says a response with Last-Modified can be cache-validated' do
          response = described_class.new(build_ok_response('', headers))
          expect(response.can_be_validated?).to be(true) # by default headers has Last-Modified.
        end

        it 'says a response with ETag can be cache-validated' do
          response = described_class.new(build_ok_response('', headers.tap do |h|
            h.delete 'last-modified'
            h['etag'] = ['123']
          end))
          expect(response.can_be_validated?).to be(true)
        end

        it 'says a response with neither Last-Modified nor ETag cannot be cache-validated' do
          response = described_class.new(build_ok_response('', headers.tap { |h| h.delete 'last-modified' }))
          expect(response.can_be_validated?).to be(false)
        end
      end
    end
  end

  describe 'cache deserialised body' do
    it 'returns the catched deserialised body when deserialise is called more than once' do
      http_response = build_ok_response
      expect(http_response).to receive(:content_type).and_return('application/xml')
      response = described_class.new(http_response)

      expect(response).to receive(:deserialise_using).once.and_return('deserialise')

      response.deserialise
      response.deserialise
    end
  end

  context 'functional', functional: true do
    let(:response) { Wrest::Native::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, Net::HTTP::Get).invoke }

    it 'is a Http::Response' do
      expect(response.class).to eq(described_class)
    end

    it 'provides access to its headers in a case-insensitive manner via []' do
      expect(response.headers['content-type']).to eq('application/xml; charset=utf-8')
      expect(response.headers['Content-Type']).to eq('application/xml; charset=utf-8')

      expect(response['Content-Type']).to eq('application/xml; charset=utf-8')
      expect(response['content-type']).to eq('application/xml; charset=utf-8')
    end
  end
end
