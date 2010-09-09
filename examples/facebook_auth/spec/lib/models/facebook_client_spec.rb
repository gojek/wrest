require 'spec_helper'

describe FacebookClient do
  let(:client){FacebookClient.new}

  it "should create a facebook authorization url given redirect url and parameters" do
    url = client.authorization_uri("http://redirect_uri", :scope => "email")
    base, query_params = url.split("?")
    base.should == "https://graph.facebook.com/oauth/authorize"
    params = Rack::Utils.parse_query(query_params)
    params["scope"].should == "email"
    params["redirect_uri"].should == "http://redirect_uri"
    params["client_id"].should_not be_nil
  end
  
  it "should exchange authentication code for the access token" do
    uri_string = "http://graph.facebook.com"
    
    FacebookClient::Config.should_receive(:[]).with("client_id").and_return("id")
    FacebookClient::Config.should_receive(:[]).with("client_secret").and_return("secret")
    FacebookClient::Config.should_receive(:[]).with("facebook_uri").and_return(uri_string)
    
    facebook_uri = mock(Wrest::Uri)
    access_token_uri = mock(Wrest::Uri)
    uri_string.should_receive(:to_uri).and_return(facebook_uri)
    facebook_uri.should_receive(:[]).with('/oauth/access_token').and_return(access_token_uri)
    response = mock("Response", :body => 'access_token=access_token')
    request_params = {:client_id => "id", :redirect_uri => "http://redirect_uri",
                      :client_secret => "secret", :code => "auth_code"}
    access_token_uri.should_receive(:post_form).with(request_params).and_return(response)
    client.acquire_access_token("http://redirect_uri","auth_code").should == "access_token"
  end
  
  context "authorized access" do
    it "should get a resource at the given path using access token" do
      uri_string = "http://graph.facebook.com"
      FacebookClient::Config.should_receive(:[]).with("facebook_uri").and_return(uri_string)
      facebook_uri = mock(Wrest::Uri)
      get_uri = mock(Wrest::Uri)
      uri_string.should_receive(:to_uri).and_return(facebook_uri)
      facebook_uri.should_receive(:[]).with('/me').and_return(get_uri)
      response = mock("Response", :body => 'body')
      get_uri.should_receive(:get).with(:access_token => "access_token").and_return(response)
      client.authorized_get("/me", "access_token").body.should == 'body'
    end
  end
end
