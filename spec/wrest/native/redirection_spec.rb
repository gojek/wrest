require File.dirname(__FILE__) + '/../../spec_helper'

describe Wrest::Native::Redirection do
  
  it "should make a request to the url in its location header and return the response" do
    mock_net_http_response = mock(Net::HTTPRedirection)
    redirect_url = 'http://redirect.com'
    redirect_uri = redirect_url.to_uri
    mock_net_http_response.should_receive(:[]).with('location').and_return(redirect_url)
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
    request_url = 'http://redirect.com'

    response = mock(Net::HTTPRedirection)
    response.stub!(:code).and_return('301')
    response.stub!(:message).and_return('')
    response.stub!(:body).and_return('')
    response.should_receive(:[]).with('location').exactly(5).times.and_return(request_url)
    
    http_connection = mock(Net::HTTP)
    http_connection.stub!(:read_timeout=)
    http_connection.should_receive(:request).exactly(5).times.and_return(response)
    
    Net::HTTP.should_receive(:new).exactly(5).times.and_return(http_connection)

    lambda{ request_url.to_uri(:follow_redirects_limit => 5).get }.should raise_error(Wrest::Exceptions::AutoRedirectLimitExceeded)
  end
end
