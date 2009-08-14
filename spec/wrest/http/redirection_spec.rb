require File.dirname(__FILE__) + '/../../spec_helper'

describe Wrest::Http::Redirection do
  
  it "should make a request to the url in its location header and return the response" do
    mock_net_http_response = mock(Net::HTTPRedirection)
    redirect_url = 'http://redirect.com'
    redirect_uri = redirect_url.to_uri
    mock_net_http_response.should_receive(:[]).with('location').and_return(redirect_url)
    mock_net_http_response.should_receive(:code).and_return('200')
    
    Wrest::Uri.should_receive(:new).with(redirect_url, {}).and_return(redirect_uri)
    
    
    after_redirect_request = Wrest::Http::Get.new(redirect_uri)
    final_mock_response = mock(Wrest::Http::Response)
    after_redirect_request.should_receive(:invoke).and_return(final_mock_response)
    
    Wrest::Http::Get.should_receive(:new).with(redirect_uri, {}, {}, {:username=>nil, :password=>nil}).and_return(after_redirect_request)
    
    response = Wrest::Http::Redirection.new(mock_net_http_response)
    response.follow.should == final_mock_response
  end
end
