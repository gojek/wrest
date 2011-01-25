require "spec_helper"

describe Wrest::Native::Redirection do
  
  it "should make a request to the url in its location header and return the response" do
    mock_net_http_response = mock(Net::HTTPRedirection)
    redirect_url = 'http://redirect.com'
    redirect_uri = redirect_url.to_uri
    mock_net_http_response.should_receive(:to_hash).and_return('location' => redirect_url)
    mock_net_http_response.should_receive(:code).and_return('200')
    
    Wrest::Uri.should_receive(:new).with(redirect_url, anything).and_return(redirect_uri)
    
    after_redirect_request = Wrest::Native::Get.new(redirect_uri)
    final_mock_response = mock(Wrest::Native::Response)
    after_redirect_request.should_receive(:invoke).and_return(final_mock_response)
    
    Wrest::Native::Get.should_receive(:new).with(redirect_uri, {}, {}, {:username=>nil, :password=>nil}).and_return(after_redirect_request)
    
    response = Wrest::Native::Redirection.new(mock_net_http_response)
    response.follow(:follow_redirects_count => 0, :follow_redirects_limit => 5).should == final_mock_response
  end
  
  it "should raise a Wrest::Exceptions::AutoRedirectLimitExceeded if there are more redirections than the limit" do

    # For n redirections, there will be n+1 Http requests. The last one being
    # the request for the actual page.

    request_url = 'http://redirect.com'

    response = mock(Net::HTTPRedirection)
    response.stub!(:code).and_return('301')
    response.stub!(:message).and_return('')
    response.stub!(:body).and_return('')
    response.stub!(:to_hash).and_return('location' => request_url)

    http_connection = mock(Net::HTTP)
    http_connection.stub!(:read_timeout=)
    http_connection.stub!(:set_debug_output)
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
