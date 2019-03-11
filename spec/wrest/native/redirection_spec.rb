require "spec_helper"

describe Wrest::Native::Redirection do

  it "should make a request to the url in its location header and return the response" do
    double_net_http_response = double(Net::HTTPRedirection)
    redirect_url = 'http://redirect.com'
    redirect_uri = redirect_url.to_uri
    double_net_http_response.should_receive(:to_hash).and_return('location' => redirect_url)
    double_net_http_response.should_receive(:code).and_return('200')

    Wrest::Uri.should_receive(:new).with(redirect_url, anything).and_return(redirect_uri)

    after_redirect_request = Wrest::Native::Get.new(redirect_uri)
    final_double_response = double(Wrest::Native::Response)
    after_redirect_request.should_receive(:invoke).and_return(final_double_response)

    Wrest::Native::Get.should_receive(:new).with(redirect_uri, {}, {}, {:username=>nil, :password=>nil}).and_return(after_redirect_request)

    response = Wrest::Native::Redirection.new(double_net_http_response)
    response.follow(:follow_redirects_count => 0, :follow_redirects_limit => 5).should == final_double_response
  end

  it "should raise a Wrest::Exceptions::AutoRedirectLimitExceeded if there are more redirections than the limit" do

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
    allow(http_connection).to receive(:open_timeout=)
    allow(http_connection).to receive(:set_debug_output)
    http_connection.should_receive(:request).exactly(5).times.and_return(response)

    Net::HTTP.should_receive(:new).exactly(5).times.and_return(http_connection)

    lambda{ request_url.to_uri(:follow_redirects_limit => 4).get }.should raise_error(Wrest::Exceptions::AutoRedirectLimitExceeded)
  end

  context "functional", :functional => true do
    it "should follow redirection (only) when follow_redirects is true" do
      after_redirect = "http://localhost:3000/redirect_n_times/4".to_uri(:follow_redirects => true).get
      after_redirect.body.should == "You've reached the end of redirection. There is only darkness beyond this."

      no_redirect = "http://localhost:3000/redirect_n_times/10".to_uri(:follow_redirects => false).get
      no_redirect.body.should be_blank
      no_redirect.http_response.code.should == "302"
    end

    it "should obey redirection limits" do
      after_redirect = "http://localhost:3000/redirect_n_times/4".to_uri(:follow_redirects => true, :follow_redirects_limit => 3)
      lambda { after_redirect.get }.should raise_exception(Wrest::Exceptions::AutoRedirectLimitExceeded)

      after_redirect = "http://localhost:3000/redirect_n_times/4".to_uri(:follow_redirects => true, :follow_redirects_limit => 4).get
      after_redirect.body.should_not be_blank
      after_redirect.http_response.code.should == "200"
    end

  end
end
