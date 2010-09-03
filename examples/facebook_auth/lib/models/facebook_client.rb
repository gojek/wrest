class FacebookClient
  Config =  {:client_id => '2ccf40089d234e4e37286af0b5fbd723',
             :client_secret => 'f221826af2afec247109effd6fd54cd2',
             :facebook_uri => 'https://graph.facebook.com'.to_uri
            }

  def authorization_uri(redirect_uri, options = {})
    request_params = {
      :client_id => Config[:client_id],
      :redirect_uri => redirect_uri
    }.merge(options)
    "#{Config[:facebook_uri]['/oauth/authorize'].uri_string}?#{request_params.to_query}"
  end

  def acquire_access_token(redirect_uri, auth_code)
    request_params = {
      :client_id => Config[:client_id],
      :redirect_uri => redirect_uri,
      :client_secret => Config[:client_secret],
      :code => auth_code
    }
    response = Config[:facebook_uri]['/oauth/access_token'].post_form(request_params).body
    params = Rack::Utils.parse_query(response)
    params['access_token']
  end
end