# frozen_string_literal: true

require 'spec_helper'

describe FacebookClient do
  let(:client) { described_class.new }

  it 'creates a facebook authorization url given redirect url and parameters' do
    url = client.authorization_uri('http://redirect_uri', scope: 'email')
    base, query_params = url.split('?')
    expect(base).to eq('https://graph.facebook.com/oauth/authorize')

    params = Rack::Utils.parse_query(query_params)

    expect(params['scope']).to eq('email')
    expect(params['redirect_uri']).to eq('http://redirect_uri')
    expect(params['client_id']).not_to be_nil
  end

  it 'exchanges authentication code for the access token' do
    uri_string = 'http://graph.facebook.com'

    FacebookClient::Config.should_receive(:[]).with('client_id').and_return('id')
    FacebookClient::Config.should_receive(:[]).with('client_secret').and_return('secret')
    FacebookClient::Config.should_receive(:[]).with('facebook_uri').and_return(uri_string)

    facebook_uri = double(Wrest::Uri)
    access_token_uri = double(Wrest::Uri)
    expect(uri_string).to receive(:to_uri).and_return(facebook_uri)
    facebook_uri.should_receive(:[]).with('/oauth/access_token').and_return(access_token_uri)
    response = double('Response', body: 'access_token=access_token')
    request_params = { client_id: 'id', redirect_uri: 'http://redirect_uri',
                       client_secret: 'secret', code: 'auth_code' }
    expect(access_token_uri).to receive(:post_form).with(request_params).and_return(response)
    expect(client.acquire_access_token('http://redirect_uri', 'auth_code')).to eq('access_token')
  end

  context 'authorized access' do
    it 'gets a resource at the given path using access token' do
      uri_string = 'http://graph.facebook.com'
      FacebookClient::Config.should_receive(:[]).with('facebook_uri').and_return(uri_string)
      facebook_uri = double(Wrest::Uri)
      get_uri = double(Wrest::Uri)
      uri_string.should_receive(:to_uri).and_return(facebook_uri)
      facebook_uri.should_receive(:[]).with('/me').and_return(get_uri)
      response = double('Response', body: 'body')
      get_uri.should_receive(:get).with(access_token: 'access_token').and_return(response)
      expect(client.authorized_get('/me', 'access_token').body).to eq('body')
    end
  end
end
