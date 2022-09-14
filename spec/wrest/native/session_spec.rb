# frozen_string_literal: true

require 'spec_helper'

module Wrest
  describe Native::Session do
    describe 'Construction' do
      it 'accepts a string uri and convert it to a Wrest::Uri' do
        uri = 'http://localhost:3000'
        expect(described_class.new(uri).uri).to eq(uri.to_uri)
      end

      it 'accepts a Wrest::Uri' do
        uri = 'http://localhost:3000'
        expect(described_class.new(uri.to_uri).uri).to eq(uri.to_uri)
      end
    end

    it 'knows how to use the connection provided to make requests' do
      uri = 'http://localhost:3000'.to_uri
      expect(uri).not_to be_https

      http = double(Net::HTTP)
      expect(Net::HTTP).to receive(:new).with('localhost', 3000).and_return(http)
      expect(http).to receive(:read_timeout=).with(60)
      expect(http).to receive(:set_debug_output).at_least(:once)

      request_one = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', { H::Connection => T::KeepAlive })
      request_two = Net::HTTP::Get.new('/bottles.xml', { H::Connection => T::KeepAlive })

      expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                   { H::Connection => T::KeepAlive }).and_return(request_one)
      expect(Net::HTTP::Get).to receive(:new).with('/bottles.xml',
                                                   { H::Connection => T::KeepAlive }).and_return(request_two)

      # TODO: Discuss whether these changes would be appropriate. Were made since the Headers responsibility was
      # totally moved to Wrest::Native directly instead of using the componenet Net::HTTP response object.
      ok_response = build_ok_response('', { Native::StandardHeaders::Connection => Native::StandardTokens::KeepAlive })
      # ok_response.should_receive(:[]).with(Native::StandardHeaders::Connection).twice.and_return(Native::StandardTokens::KeepAlive)

      expect(http).to receive(:request).with(request_one, nil).and_return(ok_response)
      expect(http).to receive(:request).with(request_two, nil).and_return(ok_response)

      described_class.new(uri) do |session|
        session.get('/glassware', build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]))
        session.get '/bottles.xml'
      end
    end

    it 'destroys the current connection if a response is returned with a Connection: Close' do
      uri = 'http://localhost:3000'.to_uri
      expect(uri).not_to be_https

      http = double(Net::HTTP)
      expect(Net::HTTP).to receive(:new).with('localhost', 3000).and_return(http)
      expect(http).to receive(:read_timeout=).with(60)

      request_one = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', { H::Connection => T::KeepAlive })
      request_two = Net::HTTP::Get.new('/bottles.xml', { H::Connection => T::KeepAlive })

      expect(Net::HTTP::Get).to receive(:new).with('/glassware?owner=Kai&type=bottle',
                                                   { H::Connection => T::KeepAlive }).and_return(request_one)
      expect(Net::HTTP::Get).to receive(:new).with('/bottles.xml',
                                                   { H::Connection => T::KeepAlive }).and_return(request_two)

      # TODO: Discuss whether these changes would be appropriate. Were made since the Headers responsibility was
      # totally moved to Wrest::Native directly instead of using the componenet Net::HTTP response object.

      ok_response = build_ok_response('', { Native::StandardHeaders::Connection => Native::StandardTokens::KeepAlive })
      # ok_response.should_receive(:[]).with(Native::StandardHeaders::Connection).once.and_return(Native::StandardTokens::KeepAlive)

      ok_response_with_connection_close = build_ok_response('',
                                                            { Native::StandardHeaders::Connection => Native::StandardTokens::Close })
      # ok_response_with_connection_close.should_receive(:[]).with(Native::StandardHeaders::Connection).once.and_return(Native::StandardTokens::Close)

      expect(http).to receive(:request).with(request_one, nil).and_return(ok_response)
      expect(http).to receive(:request).with(request_two, nil).and_return(ok_response_with_connection_close)
      expect(http).to receive(:set_debug_output).twice

      described_class.new(uri) do |session|
        session.get('/glassware', build_ordered_hash([[:owner, 'Kai'], [:type, 'bottle']]))
        expect(session.instance_variable_get('@connection')).to eq(http)
        session.get '/bottles.xml'
        expect(session.instance_variable_get('@connection')).to be_nil
      end
    end

    context 'functional', functional: true do
      it 'should know how to use the connection provided to make requests'
      def cont
        Native::Session.new('http://github.com') do |session|
          expect(session.get('/repositories')).not_to be_connection_closed
        end
      end

      it 'has a empty string for a body' do
        expect('http://localhost:3000/no_body'.to_uri.get.body).to eq(' ')
        expect('http://localhost:3000/nothing'.to_uri.get.body).to eq(' ')
        expect('http://localhost:3000/nothing'.to_uri.post.body).to eq(' ')
        expect('http://localhost:3000/no_bodies.xml'.to_uri.post.body).to eq(' ')
      end
    end
  end
end
