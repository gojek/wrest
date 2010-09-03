require ::File.expand_path('../../config/boot', __FILE__)
require ::File.expand_path('../../config/settings', __FILE__)
require ::File.expand_path('../models/facebook_client', __FILE__)

class FacebookAuth < Sinatra::Application
  get '/facebook_profile' do
    if session[:access_token].nil?
      redirect '/facebook_authenticate'
    end
    response = Settings[:facebook_uri]['/me'].get(:access_token => session[:access_token])
    ActiveSupport::JSON.decode(response.body)
  end
  
  get '/facebook_authenticate' do
    request_params = {
      :client_id => Settings[:client_id],
      :redirect_uri => facebook_post_authentication_url,
      :scope => 'offline_access'
    }
    redirect "#{Settings[:facebook_uri]['/oauth/authorize'].uri_string}?#{request_params.to_query}"
  end
  
  get '/facebook_authenticated' do
    request_params = {
      :client_id => Settings[:client_id],
      :redirect_uri => facebook_post_authentication_url,
      :client_secret => Settings[:client_secret],
      :code => params[:code]
    }
    response = Settings[:facebook_uri]['/oauth/access_token'].post_form(request_params).body
    params = Rack::Utils.parse_query(response)
    session[:access_token] = params['access_token']
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