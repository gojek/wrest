require File.expand_path('../../config/boot', __FILE__)
require File.expand_path('../models/facebook_client', __FILE__)
require File.expand_path('../models/facebook_user', __FILE__)
require File.expand_path('../models/facebook_profile', __FILE__)
require File.expand_path('../models/wall_post', __FILE__)

module FacebookAuth
  class Application < Sinatra::Application
    get '/' do
      erb :home
    end
  
    get '/facebook_profile' do
      require_facebook_authentication(request.fullpath)
      erb :facebook_profile, :locals => { :profile => facebook_user.profile }
    end

    get '/new_wall_post' do
      require_facebook_authentication(request.fullpath)
      erb :new_wall_post
    end

    post '/wall_post' do
      require_facebook_authentication('/new_wall_post')
      message = params[:message]
      erb :successful_wall_post, :locals => { :message => message }
    end
    
    get '/facebook_authenticate' do
      redirect FacebookClient.new.authorization_uri(facebook_post_authentication_url, :scope => "offline_access")
    end

    get '/facebook_authenticated' do
      session[:access_token] = FacebookClient.new.acquire_access_token(facebook_post_authentication_url, params[:code])
      redirect session.delete(:return_to) || '/facebook_profile'
    end

    helpers do
      def require_facebook_authentication(return_to)
        unless facebook_user.authenticated?
          session[:return_to] = return_to
          redirect '/facebook_authenticate'
        end
      end
      
      def facebook_user
        @facebook_user ||= FacebookUser.new(session[:access_token])
      end
    
      def app_base_url
        @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
      end
    
      def facebook_post_authentication_url
        "#{app_base_url}/facebook_authenticated"
      end
    end
  end
end