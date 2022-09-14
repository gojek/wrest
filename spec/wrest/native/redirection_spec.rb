# frozen_string_literal: true

require 'spec_helper'

describe Wrest::Native::Redirection do
  it 'makes a request to the url in its location header and return the response' do
    double_net_http_response = double(Net::HTTPRedirection)
    redirect_url = 'http://redirect.com'
    redirect_uri = redirect_url.to_uri
    expect(double_net_http_response).to receive(:to_hash).and_return('location' => redirect_url)
    expect(double_net_http_response).to receive(:code).and_return('200')

    expect(Wrest::Uri).to receive(:new).with(redirect_url, anything).and_return(redirect_uri)

    after_redirect_request = Wrest::Native::Get.new(redirect_uri)
    final_double_response = double(Wrest::Native::Response)
    expect(after_redirect_request).to receive(:invoke).and_return(final_double_response)

    expect(Wrest::Native::Get).to receive(:new).with(redirect_uri, {}, {},
                                                     { username: nil, password: nil }).and_return(after_redirect_request)

    response = described_class.new(double_net_http_response)
    expect(response.follow(follow_redirects_count: 0, follow_redirects_limit: 5)).to eq(final_double_response)
  end

  it 'raises a Wrest::Exceptions::AutoRedirectLimitExceeded if there are more redirections than the limit' do
    # For n redirections, there will be n+1 Http requests. The last one being
    # the request for the actual page.

    request_url = 'http://redirect.com'

    response = double(Net::HTTPRedirection)
    allow(response).to receive(:code).and_return('301')
    allow(response).to receive(:message).and_return('')
    allow(response).to receive(:body).and_return('')
    allow(response).to receive(:to_hash).and_return('location' => request_url)

    http_connection = double(Net::HTTP)
    allow(http_connection).to receive(:read_timeout=)
    allow(http_connection).to receive(:set_debug_output)
    expect(http_connection).to receive(:request).exactly(5).times.and_return(response)

    expect(Net::HTTP).to receive(:new).exactly(5).times.and_return(http_connection)

    expect do
      request_url.to_uri(follow_redirects_limit: 4).get
    end.to raise_error(Wrest::Exceptions::AutoRedirectLimitExceeded)
  end

  context 'functional', functional: true do
    it 'follows redirection (only) when follow_redirects is true' do
      after_redirect = 'http://localhost:3000/redirect_n_times/4'.to_uri(follow_redirects: true).get
      expect(after_redirect.body).to eq("You've reached the end of redirection. There is only darkness beyond this.")

      no_redirect = 'http://localhost:3000/redirect_n_times/10'.to_uri(follow_redirects: false).get
      expect(Wrest::Utils.string_blank?(no_redirect.body)).to be(true)
      expect(no_redirect.http_response.code).to eq('302')
    end

    it 'obeys redirection limits' do
      after_redirect = 'http://localhost:3000/redirect_n_times/4'.to_uri(follow_redirects: true,
                                                                         follow_redirects_limit: 3)
      expect { after_redirect.get }.to raise_exception(Wrest::Exceptions::AutoRedirectLimitExceeded)

      after_redirect = 'http://localhost:3000/redirect_n_times/4'.to_uri(follow_redirects: true,
                                                                         follow_redirects_limit: 4).get
      expect(Wrest::Utils.string_blank?(after_redirect.body)).not_to be(true)
      expect(after_redirect.http_response.code).to eq('200')
    end
  end
end
