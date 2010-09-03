require ::File.expand_path('../../config/boot', __FILE__)
require ::File.expand_path('../models/facebook_client', __FILE__)

class FacebookAuth < Sinatra::Application
  get '/facebook_profile' do
    if session[:access_token].nil?
      redirect '/facebook_authenticate'
    end
    response = FacebookClient::Config[:facebook_uri]['/me'].get(:access_token => session[:access_token])
    response.body
  end
  
  get '/facebook_authenticate' do
    redirect FacebookClient.new.authorization_uri(facebook_post_authentication_url, :scope => "offline_access")
  end
  
  get '/facebook_authenticated' do
    session[:access_token] = FacebookClient.new.acquire_access_token(facebook_post_authentication_url, params[:code])
    redirect '/facebook_profile'
  end
  
  helpers do
    def app_base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end
    
    def facebook_post_authentication_url
      "#{app_base_url}/facebook_authenticated"
    end
  end
end