# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

RSpec.describe Wrest::Uri do
  it 'responds to the five http actions' do
    uri = described_class.new('http://localhost')
    expect(uri).to respond_to(:get)
    expect(uri).to respond_to(:post)
    expect(uri).to respond_to(:put)
    expect(uri).to respond_to(:patch)
    expect(uri).to respond_to(:delete)
  end

  it 'handles URIs' do
    expect(described_class.new('https://localhost:3000')).to eq(described_class.new(URI.parse('https://localhost:3000')))
  end

  it 'knows when it is https' do
    expect(described_class.new('https://localhost:3000')).to be_https
  end

  context 'UriTemplate' do
    it 'is able to create a UriTemplate given a uri' do
      expect('http://localhost:3000'.to_uri.to_template('/user/:name')).to eq(Wrest::UriTemplate.new('http://localhost:3000/user/:name'))
    end

    it 'passes options to the uriTemplate being built' do
      expect('http://localhost:3000'.to_uri(name: 'abc').to_template('/user/:name').to_uri).to eq('http://localhost:3000/user/abc'.to_uri)
    end

    it 'handles / positions with wisdom while creating UriTemplate from a given Uri' do
      expect('http://localhost:3000/'.to_uri.to_template('/user/:name')).to eq(Wrest::UriTemplate.new('http://localhost:3000/user/:name'))
      expect('http://localhost:3000'.to_uri.to_template('/user/:name')).to eq(Wrest::UriTemplate.new('http://localhost:3000/user/:name'))
      expect('http://localhost:3000/'.to_uri.to_template('user/:name')).to eq(Wrest::UriTemplate.new('http://localhost:3000/user/:name'))
      expect('http://localhost:3000'.to_uri.to_template('user/:name')).to eq(Wrest::UriTemplate.new('http://localhost:3000/user/:name'))
    end
  end

  it 'knows when it is not https' do
    expect(described_class.new('http://localhost:3000')).not_to be_https
  end

  context 'extension' do
    it 'knows how to build a new uri from an existing one by appending a path' do
      expect(described_class.new('http://localhost:3000')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
    end

    it 'does not lose bits of the path along the way' do
      expect(described_class.new('http://localhost:3000/ooga')['/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
    end

    it 'handles / positions with wisdom' do
      expect(described_class.new('http://localhost:3000/')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
      expect(described_class.new('http://localhost:3000')['/ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
      expect(described_class.new('http://localhost:3000/')['ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
      expect(described_class.new('http://localhost:3000')['ooga/booga']).to eq(described_class.new('http://localhost:3000/ooga/booga'))
    end
  end

  it 'knows its full path' do
    expect(described_class.new('http://localhost:3000/ooga').full_path).to eq('/ooga')
    expect(described_class.new('http://localhost:3000/ooga?foo=meh&bar=1').full_path).to eq('/ooga?foo=meh&bar=1')
  end

  it 'knows its host' do
    expect(described_class.new('http://localhost:3000/ooga').host).to eq('localhost')
  end

  it 'knows its port' do
    expect(described_class.new('http://localhost:3000/ooga').port).to eq(3000)
    expect(described_class.new('http://localhost/ooga').port).to eq(80)
  end

  it 'includes the username and password while building a new uri if no options are provided' do
    expect(described_class.new(
      'http://localhost:3000',
      username: 'foo',
      password: 'bar'
    )['/ooga/booga']).to eq(described_class.new(
                              'http://localhost:3000/ooga/booga',
                              username: 'foo',
                              password: 'bar'
                            ))
  end

  it 'uses the username and password provided while building a new uri if present' do
    uri = described_class.new('http://localhost:3000', username: 'foo', password: 'bar')
    expect(uri.username).to eq('foo')
    expect(uri.password).to eq('bar')

    extended_uri = uri['/ooga/booga', { username: 'meh', password: 'baz' }]
    expect(extended_uri.username).to eq('meh')
    expect(extended_uri.password).to eq('baz')
  end

  it 'knows how to produce its uri as a string' do
    expect(described_class.new('http://localhost:3000').uri_string).to eq('http://localhost:3000')
    expect(described_class.new('http://localhost:3000').to_s).to eq('http://localhost:3000')
    expect(described_class.new('http://localhost:3000', username: 'foo', password: 'bar').to_s).to eq('http://localhost:3000')
    expect(described_class.new('http://foo:bar@localhost:3000').to_s).to eq('http://foo:bar@localhost:3000')
  end

  describe 'Equals' do
    # rubocop:disable RSpec/IdenticalEqualityAssertion
    it 'understands equality' do
      expect(described_class.new('https://localhost:3000/ooga')).not_to be_nil
      expect(described_class.new('https://localhost:3000/ooga')).not_to eq('https://localhost:3000/ooga')
      expect(described_class.new('https://localhost:3000/ooga')).not_to eq(described_class.new('https://localhost:3000/booga'))

      expect(described_class.new('https://ooga:booga@localhost:3000/ooga')).not_to eq(described_class.new('https://foo:bar@localhost:3000/booga'))
      expect(described_class.new('http://ooga:booga@localhost:3000/ooga')).not_to eq(described_class.new('http://foo:bar@localhost:3000/booga'))
      expect(described_class.new('http://localhost:3000/ooga')).not_to eq(described_class.new('http://foo:bar@localhost:3000/booga'))

      expect(described_class.new('http://localhost:3000?owner=kai&type=bottle')).not_to eq(described_class.new('http://localhost:3000/'))
      expect(described_class.new('http://localhost:3000?owner=kai&type=bottle')).not_to eq(described_class.new('http://localhost:3000?'))
      expect(described_class.new('http://localhost:3000?owner=kai&type=bottle')).not_to eq(described_class.new('http://localhost:3000?type=bottle&owner=kai'))

      expect(described_class.new('https://localhost:3000')).not_to eq(described_class.new('https://localhost:3500'))
      expect(described_class.new('https://localhost:3000')).not_to eq(described_class.new('http://localhost:3000'))
      expect(described_class.new('http://localhost:3000', username: 'ooga', password: 'booga')).not_to eq(described_class.new('http://ooga:booga@localhost:3000'))

      expect(described_class.new('http://localhost:3000')).to eq(described_class.new('http://localhost:3000'))
      expect(described_class.new('http://localhost:3000', username: 'ooga',
                                                          password: 'booga')).to eq(described_class.new('http://localhost:3000',
                                                                                                        username: 'ooga', password: 'booga'))
      expect(described_class.new('http://ooga:booga@localhost:3000')).to eq(described_class.new('http://ooga:booga@localhost:3000'))
    end

    it 'has the same hash code if it is the same uri' do
      expect(described_class.new('https://localhost:3000').hash).to eq(described_class.new('https://localhost:3000').hash)
      expect(described_class.new('http://ooga:booga@localhost:3000').hash).to eq(described_class.new('http://ooga:booga@localhost:3000').hash)
      expect(described_class.new('http://localhost:3000', username: 'ooga',
                                                          password: 'booga').hash).to eq(described_class.new('http://localhost:3000',
                                                                                                             username: 'ooga', password: 'booga').hash)

      expect(described_class.new('https://localhost:3001').hash).not_to eq(described_class.new('https://localhost:3000').hash)
      expect(described_class.new('https://ooga:booga@localhost:3000').hash).not_to eq(described_class.new('https://localhost:3000').hash)
      expect(described_class.new('https://localhost:3000', username: 'ooga', password: 'booga').hash).not_to eq(described_class.new('https://localhost:3000').hash)
      expect(described_class.new('https://localhost:3000', username: 'ooga',
                                                           password: 'booga').hash).not_to eq(described_class.new('http://localhost:3000',
                                                                                                                  username: 'foo', password: 'bar').hash)
    end
    # rubocop:enable RSpec/IdenticalEqualityAssertion
  end

  describe 'Cloning' do
    let(:original) { described_class.new('http://localhost:3000/ooga', default_headers: { Wrest::H::ContentType => Wrest::T::FormEncoded }) }
    let(:clone) { original.clone }

    it 'is equal to its clone' do
      expect(original).to eq(clone)
    end

    it 'is not the same object as the clone' do
      expect(original).not_to be_equal(clone)
    end

    it 'allows options to be changed when building the clone' do
      clone = original.clone(username: 'kaiwren', password: 'bottle')
      expect(original).not_to eq(clone)
      expect(clone.username).to eq('kaiwren')
      expect(clone.password).to eq('bottle')
      expect(original.username).to be_nil
    end

    context 'default headers' do
      it 'merges the default headers' do
        expect(original.clone(default_headers: { Wrest::H::Connection => Wrest::T::KeepAlive }).default_headers).to eq(
          Wrest::H::Connection => Wrest::T::KeepAlive,
          Wrest::H::ContentType => Wrest::T::FormEncoded
        )
      end

      it 'ensures incoming defaults have priority' do
        expect(original.clone(default_headers: { Wrest::H::ContentType => Wrest::T::ApplicationXml }).default_headers).to eq(
          Wrest::H::ContentType => Wrest::T::ApplicationXml
        )
      end
    end
  end

  describe 'HTTP actions' do
    def setup_http
      http = double(Net::HTTP)
      expect(Net::HTTP).to receive(:new).with('localhost', 3000).and_return(http)
      expect(http).to receive(:read_timeout=).with(60)
      expect(http).to receive(:set_debug_output).with(nil)
      http
    end

    context 'GET' do
      it 'knows how to get' do
        uri = 'http://localhost:3000/glassware'.to_uri

        http = setup_http

        request = Net::HTTP::Get.new('/glassware', {})
        expect(Net::HTTP::Get).to receive(:new).with('/glassware', {}).and_return(request)

        expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

        uri.get
      end

      context 'query parameters' do
        it 'knows how to get with parameters' do
          uri = 'http://localhost:3000/glassware'.to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', { 'page' => '2', 'per_page' => '5' })
          expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                       { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get(build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]), page: '2', per_page: '5')
        end

        it 'knows how to get with parameters included in the uri' do
          uri = 'http://localhost:3000/glassware?owner=Kai&type=bottle'.to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', { 'page' => '2', 'per_page' => '5' })
          expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                       { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get({}, page: '2', per_page: '5')
        end

        it 'propagates http auth options while being converted to Template and back' do
          base = 'http://localhost:3000/'.to_uri(username: 'ooga', password: 'bar')
          template = base.to_template('/search/:search')
          uri = template.to_uri(search: 'kaiwren')
          request = Wrest::Native::Get.new(uri, {}, {}, { username: 'ooga', password: 'bar' })
          expect(Wrest::Http::Get).to receive(:new).with(uri, {}, {},
                                                         { username: 'ooga', password: 'bar' }).and_return(request)

          http_request = double(Net::HTTP::Get, method: 'GET', hash: {})
          expect(http_request).to receive(:basic_auth).with('ooga', 'bar')
          expect(request).to receive(:http_request).at_least(:once).and_return(http_request)
          expect(request).to receive(:do_request).and_return(double(Net::HTTPOK, code: '200', message: 'OK',
                                                                                 body: '', to_hash: {}))
          uri.get
        end

        it 'knows how to get with a ? appended to the uri and no appended parameters' do
          uri = 'http://localhost:3000/glassware?'.to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware', { 'page' => '2', 'per_page' => '5' })
          expect(Net::HTTP::Get).to receive(:new).with('/glassware',
                                                       { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get({}, page: '2', per_page: '5')
        end

        it 'knows how to get with a ? appended to the uri and specified parameters' do
          uri = 'http://localhost:3000/glassware?'.to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware?owner=kai&type=bottle', { 'page' => '2', 'per_page' => '5' })

          expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                       { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get(build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]), page: '2', per_page: '5')
        end

        it 'knows how to get with parameters appended to the uri and specfied parameters' do
          uri = 'http://localhost:3000/glassware?owner=kai&type=bottle'.to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware?owner=kai&type=bottle&param1=one&param2=two',
                                       { 'page' => '2', 'per_page' => '5' })

          expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=kai&type=bottle&param1=one&param2=two',
                                                       { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get(build_ordered_hash([[:param1, 'one'], [:param2, 'two']]), page: '2', per_page: '5')
        end

        it 'knows how to get with parameters but without any headers' do
          uri = 'http://localhost:3000/glassware'.to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {})
          expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle', {}).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get(build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]))
        end
      end
    end

    it 'knows how to post' do
      uri = 'http://localhost:3000/glassware'.to_uri

      http = setup_http

      request = Net::HTTP::Post.new('/glassware', { 'page' => '2', 'per_page' => '5' })
      expect(Net::HTTP::Post).to receive(:new).with('/glassware',
                                                    { 'page' => '2', 'per_page' => '5' }).and_return(request)

      expect(http).to receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

      uri.post '<ooga>Booga</ooga>', page: '2', per_page: '5'
    end

    it 'knows how to post form-encoded parameters using Uri#post_form' do
      uri = 'http://localhost:3000/glassware'.to_uri

      http = setup_http

      request = Net::HTTP::Post.new('/glassware', { 'page' => '2', 'per_page' => '5' })
      expect(Net::HTTP::Post).to receive(:new).with('/glassware',
                                                    hash_including('page' => '2', 'per_page' => '5',
                                                                   Wrest::H::ContentType => Wrest::T::FormEncoded)).and_return(request)

      expect(http).to receive(:request).with(request, 'foo=bar&ooga=booga').and_return(build_ok_response)
      uri.post_form(build_ordered_hash([[:foo, 'bar'], [:ooga, 'booga']]), page: '2', per_page: '5')
    end

    it 'knows how to put' do
      uri = 'http://localhost:3000/glassware'.to_uri

      http = setup_http

      request = Net::HTTP::Put.new('/glassware', { 'page' => '2', 'per_page' => '5' })
      expect(Net::HTTP::Put).to receive(:new).with('/glassware', { 'page' => '2', 'per_page' => '5' }).and_return(request)

      expect(http).to receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

      uri.put '<ooga>Booga</ooga>', page: '2', per_page: '5'
    end

    context 'PATCH' do
      it 'knows how to patch' do
        uri = 'http://localhost:3000/glassware'.to_uri

        http = setup_http

        request = Net::HTTP::Patch.new('/glassware', { 'page' => '2', 'per_page' => '5' })
        expect(Net::HTTP::Patch).to receive(:new).with('/glassware',
                                                       { 'page' => '2', 'per_page' => '5' }).and_return(request)

        expect(http).to receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.patch '<ooga>Booga</ooga>', page: '2', per_page: '5'
      end
    end

    context 'DELETE' do
      it 'knows how to delete' do
        uri = 'http://localhost:3000/glassware'.to_uri

        http = setup_http

        request = Net::HTTP::Delete.new('/glassware?owner=Kai&type=bottle', { 'page' => '2', 'per_page' => '5' })
        expect(Net::HTTP::Delete).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                        { 'page' => '2', 'per_page' => '5' }).and_return(request)

        expect(http).to receive(:request).with(request, nil).and_return(build_ok_response(nil))

        uri.delete(build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]), page: '2', per_page: '5')
      end

      context 'query parameters' do
        it 'knows how to delete with parameters included in the uri' do
          uri = 'http://localhost:3000/glassware?owner=Kai&type=bottle'.to_uri

          http = setup_http

          request = Net::HTTP::Delete.new('/glassware?owner=Kai&type=bottle', { 'page' => '2', 'per_page' => '5' })
          expect(Net::HTTP::Delete).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                          { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response(nil))

          uri.delete({}, page: '2', per_page: '5')
        end

        it 'knows how to delete with a ? appended to the uri and no appended parameters' do
          uri = 'http://localhost:3000/glassware?'.to_uri

          http = setup_http

          request = Net::HTTP::Delete.new('/glassware', { 'page' => '2', 'per_page' => '5' })
          expect(Net::HTTP::Delete).to receive(:new).with('/glassware',
                                                          { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response(nil))

          uri.delete({}, page: '2', per_page: '5')
        end

        it 'knows how to delete with a ? appended to the uri and specified parameters' do
          uri = 'http://localhost:3000/glassware?'.to_uri

          http = setup_http

          request = Net::HTTP::Delete.new('/glassware?owner=kai&type=bottle', { 'page' => '2', 'per_page' => '5' })

          expect(Net::HTTP::Delete).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                          { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response(nil))

          uri.delete(build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]), page: '2', per_page: '5')
        end

        it 'knows how to delete with parameters appended to the uri and specfied parameters' do
          uri = 'http://localhost:3000/glassware?owner=kai&type=bottle'.to_uri

          http = setup_http

          request = Net::HTTP::Delete.new('/glassware?owner=kai&type=bottle', { 'page' => '2', 'per_page' => '5' })

          expect(Net::HTTP::Delete).to receive(:new).with('/glassware?owner=kai&type=bottle&param1=one&param2=two',
                                                          { 'page' => '2', 'per_page' => '5' }).and_return(request)

          expect(http).to receive(:request).with(request, nil).and_return(build_ok_response(nil))

          uri.delete(build_ordered_hash([[:param1, 'one'], [:param2, 'two']]), page: '2', per_page: '5')
        end
      end
    end

    it 'knows how to ask for options on a URI' do
      uri = 'http://localhost:3000/glassware'.to_uri

      http = setup_http

      request = Net::HTTP::Options.new('/glassware')
      expect(Net::HTTP::Options).to receive(:new).with('/glassware', {}).and_return(request)

      expect(http).to receive(:request).with(request, nil).and_return(build_ok_response(nil))

      uri.options
    end

    it 'does not mutate state of the uri across requests' do
      uri = 'http://localhost:3000/glassware'.to_uri

      http = double(Net::HTTP)
      expect(Net::HTTP).to receive(:new).with('localhost', 3000).at_least(:once).and_return(http)
      expect(http).to receive(:read_timeout=).at_least(:once).with(60)
      expect(http).to receive(:set_debug_output).at_least(:once)

      request_get = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', { 'page' => '2', 'per_page' => '5' })
      expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                   { 'page' => '2', 'per_page' => '5' }).and_return(request_get)

      request_post = Net::HTTP::Post.new('/glassware', { 'page' => '2', 'per_page' => '5' })
      expect(Net::HTTP::Post).to receive(:new).with('/glassware',
                                                    { 'page' => '2', 'per_page' => '5' }).and_return(request_post)

      expect(http).to receive(:request).with(request_get, nil).and_return(build_ok_response)
      expect(http).to receive(:request).with(request_post, '<ooga>Booga</ooga>').and_return(build_ok_response)

      uri.get(build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]), page: '2', per_page: '5')
      uri.post '<ooga>Booga</ooga>', page: '2', per_page: '5'
    end

    def setup_connection
      connection = double('Net::HTTP')
      response200 = double(Net::HTTPOK, code: '200', message: 'OK', body: '', to_hash: {})
      allow(connection).to receive(:set_debug_output)
      allow(connection).to receive(:request).and_return(response200)
      connection
    end

    http_methods = %w[get delete post_multipart put_multipart]
    http_methods.each do |http_method|
      context http_method.to_s do
        before(:all) { require 'wrest/multipart' }

        it 'calls the given block with a Callback object' do
          connection = setup_connection
          uri = 'http://localhost:3000/'.to_uri
          allow(uri).to receive(:create_connection).and_return(connection)
          callback_called = false
          uri.send(http_method.to_sym) do |callback|
            expect(callback).to be_an_instance_of(Wrest::Callback)
            callback_called = true
          end
          expect(callback_called).to be_truthy
        end

        it 'executes the request callback after receiving a successful response' do
          connection = setup_connection
          on_ok = false
          uri = 'http://localhost:3000/'.to_uri
          allow(uri).to receive(:create_connection).and_return(connection)
          uri.send(http_method.to_sym) do |callback|
            callback.on_ok { |_response| on_ok = true }
          end
          expect(on_ok).to be_truthy
        end

        it 'executes the uri callback after receiving a successful response' do
          connection = setup_connection
          on_ok = false
          uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
          allow(uri).to receive(:create_connection).and_return(connection)
          uri.send(http_method.to_sym)
          expect(on_ok).to be_truthy
        end

        it 'executes the uri callback after receiving a successful response on sub path' do
          connection = setup_connection
          on_ok = false
          base_uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
          uri = base_uri['glassware']
          allow(uri).to receive(:create_connection).and_return(connection)
          uri.send(http_method.to_sym)
          expect(on_ok).to be_truthy
        end

        it 'executes both callbacks after the successful response is received' do
          connection = setup_connection
          on_ok = false
          another_ok = false
          uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
          allow(uri).to receive(:create_connection).and_return(connection)
          block = lambda do |callback|
            callback.on_ok { |_response| another_ok = true }
          end
          uri.send(http_method.to_sym) do |callback|
            callback.on_ok { |_response| another_ok = true }
          end
          expect(on_ok).to be_truthy
          expect(another_ok).to be_truthy
        end
      end
    end

    %w[put post].each do |http_method|
      context http_method.to_s do
        context 'Native API' do
          it 'yields callback object if a block is given for Uri::get' do
            connection = setup_connection
            uri = 'http://localhost:3000/'.to_uri
            allow(uri).to receive(:create_connection).and_return(connection)
            callback_called = false
            uri.send(http_method.to_sym) do |callback|
              expect(callback).to be_a(Wrest::Callback)
              callback_called = true
            end
            expect(callback_called).to be_truthy
          end

          it 'executes the request callback after receiving a successful response' do
            connection = setup_connection
            on_ok = false
            uri = 'http://localhost:3000/'.to_uri
            allow(uri).to receive(:create_connection).and_return(connection)
            uri.send(http_method.to_sym) do |callback|
              callback.on_ok { |_response| on_ok = true }
            end
            expect(on_ok).to be_truthy
          end

          it 'executes the uri callback after receiving a successful response' do
            connection = setup_connection
            on_ok = false
            uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
            allow(uri).to receive(:create_connection).and_return(connection)
            uri.send(http_method.to_sym)
            expect(on_ok).to be_truthy
          end

          it 'executes the uri callback after receiving a successful response on subpath' do
            connection = setup_connection
            on_ok = false
            base_uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
            uri = base_uri['glassware']
            allow(uri).to receive(:create_connection).and_return(connection)
            uri.send(http_method.to_sym)
            expect(on_ok).to be_truthy
          end

          it 'executes both callbacks after the successful response is received' do
            connection = setup_connection
            on_ok = false
            another_ok = false
            uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
            allow(uri).to receive(:create_connection).and_return(connection)
            block = lambda do |callback|
              callback.on_ok { |_response| another_ok = true }
            end
            uri.send(http_method.to_sym) do |callback|
              callback.on_ok { |_response| another_ok = true }
            end
            expect(on_ok).to be_truthy
            expect(another_ok).to be_truthy
          end
        end
      end
    end

    context 'post_form' do
      it 'calls the given block with a Callback object' do
        connection = setup_connection
        uri = 'http://localhost:3000/'.to_uri
        allow(uri).to receive(:create_connection).and_return(connection)
        callback_called = false
        uri.post_form do |callback|
          expect(callback).to be_a(Wrest::Callback)
          callback_called = true
        end
        expect(callback_called).to be_truthy
      end

      it 'executes the request callback after receiving a successful response' do
        connection = setup_connection
        on_ok = false
        uri = 'http://localhost:3000/'.to_uri
        allow(uri).to receive(:create_connection).and_return(connection)
        request = Wrest::Native::Post.new(uri)
        uri.post_form do |callback|
          callback.on_ok { |_response| on_ok = true }
        end
        expect(on_ok).to be_truthy
      end

      it 'executes the uri callback after receiving a successful response' do
        connection = setup_connection
        on_ok = false
        uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
        allow(uri).to receive(:create_connection).and_return(connection)
        uri.post_form
        expect(on_ok).to be_truthy
      end

      it 'executes the uri callback after receiving a successful response on sub path' do
        connection = setup_connection
        on_ok = false
        base_uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
        uri = base_uri['glassware']
        allow(uri).to receive(:create_connection).and_return(connection)
        uri.post_form
        expect(on_ok).to be_truthy
      end

      it 'executes both callbacks after the successful response is received' do
        connection = setup_connection
        on_ok = false
        another_ok = false
        uri = 'http://localhost:3000/'.to_uri(callback: { 200 => ->(_response) { on_ok = true } })
        allow(uri).to receive(:create_connection).and_return(connection)
        block = lambda do |callback|
          callback.on_ok { |_response| another_ok = true }
        end
        uri.post_form do |callback|
          callback.on_ok { |_response| another_ok = true }
        end
        expect(on_ok).to be_truthy
        expect(another_ok).to be_truthy
      end
    end

    context 'default headers' do
      let(:oauth_header) { { 'Authorization' => 'OAuth YOUR_ACCESS_TOKEN' } }
      let(:alternative_oauth_header) { { 'Authorization' => 'OAuth YOUR_OTHER_ACCESS_TOKEN' } }
      let(:content_type_header) { { 'Content-Type' => 'application/json' } }
      let(:uri) { 'http://ooga.com'.to_uri(default_headers: oauth_header) }

      it 'lets incoming default_headers take precedence when the Uri is extended' do
        expect(uri['/foo', { default_headers: content_type_header }].default_headers).to eq(content_type_header)
      end

      {
        'get' => {},
        'delete' => {},
        'post' => '',
        'put' => ''
      }.each do |verb, blank_first_param_value|
        context verb.upcase.to_s do
          it 'sets the default headers if there are no request headers' do
            expect(uri.send("build_#{verb}").headers).to eq(oauth_header)
          end

          it 'merges the default headers into the request headers' do
            expect(uri.send("build_#{verb}", blank_first_param_value,
                            content_type_header).headers).to eq(oauth_header.merge(content_type_header))
          end

          it 'lets the incoming headers take precedent over the defaults' do
            expect(uri.send("build_#{verb}", blank_first_param_value,
                            alternative_oauth_header).headers).to eq(alternative_oauth_header)
          end
        end
      end

      context 'POST (form-encoded)' do
        it 'sets the default headers if there are no request headers' do
          expect(uri.build_post_form.headers).to eq(oauth_header.merge(Wrest::H::ContentType => Wrest::T::FormEncoded))
        end

        it 'merges the default headers into the request headers' do
          expect(uri.build_post_form({}, content_type_header).headers).to eq(
            oauth_header.merge(content_type_header).merge(Wrest::H::ContentType => Wrest::T::FormEncoded)
          )
        end

        it 'lets the incoming headers take precedent over the defaults' do
          expect(uri.build_post_form({},
                                     alternative_oauth_header).headers).to eq(alternative_oauth_header.merge(Wrest::H::ContentType => Wrest::T::FormEncoded))
        end
      end
    end

    context 'asynchronous', functional: true do
      let(:hash) { {} }

      context 'default backend' do
        it 'executes the request and the given callback on a separate thread by default' do
          uri = 'http://localhost:3000/no_body'.to_uri(callback: { 200 => lambda { |_response|
            hash['success'] = true
          } })
          uri.get_async

          sleep 0.1
          expect(hash).to be_key('success')
        end
      end

      asynchronous_backends = { 'threads' => 'default_to_threads!', 'eventmachine' => 'default_to_em!' }
      asynchronous_backends.each do |backend_type, backend_method|
        context backend_type.to_s do
          before do
            Wrest::AsyncRequest.send(backend_method.to_sym)
          end

          context 'GET' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/no_body'.to_uri(callback: { 200 => lambda { |_response|
                hash['success'] = true
              } })
              uri.get_async

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end

          context 'PUT' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/not_found'.to_uri(callback: { 404 => lambda { |_response|
                hash['success'] = true
              } })
              uri.put_async

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end

          context 'POST' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/nothing'.to_uri(callback: { 200 => lambda { |_response|
                hash['success'] = true
              } })
              uri.post_async

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end

          context 'DELETE' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/not_found'.to_uri(callback: { 404 => lambda { |_response|
                hash['success'] = true
              } })
              uri.delete_async

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end

          context 'POST FORM' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/not_found'.to_uri(callback: { 404 => lambda { |_response|
                hash['success'] = true
              } })
              uri.post_form_async

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end

          context 'POST MULTIPART' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/uploads'.to_uri(callback: { 200 => lambda { |_response|
                hash['success'] = true
              } })
              file_name = File.expand_path("#{Wrest::Root}/../Rakefile")
              file = File.open(file_name)
              uri.post_multipart_async('file' => UploadIO.new(file, 'text/plain', file_name), :calback => { 200 => lambda { |_response|
                hash['success'] = true
              } })

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end

          context 'PUT MULTIPART' do
            it 'executes the request and the given callback' do
              uri = 'http://localhost:3000/uploads/1'.to_uri(callback: { 200 => lambda { |_response|
                hash['success'] = true
              } })
              file_name = File.expand_path("#{Wrest::Root}/../Rakefile")
              file = File.open(file_name)
              uri.put_multipart_async('file' => UploadIO.new(file, 'text/plain', file_name), :calback => { 200 => lambda { |_response|
                hash['success'] = true
              } })

              sleep 0.1
              expect(hash).to be_key('success')
            end
          end
        end
      end
    end
  end
end
