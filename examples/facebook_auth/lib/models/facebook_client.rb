class FacebookClient

  Config = YAML.load_file(File.expand_path('../../../config/facebook.yml', __FILE__))

  def authorization_uri(redirect_uri, options = {})
    request_params = {
      :client_id => Config["client_id"],
      :redirect_uri => redirect_uri
    }.merge(options)
    "#{base_url['/oauth/authorize'].uri_string}?#{request_params.to_query}"
  end

  def acquire_access_token(redirect_uri, auth_code)
    request_params = {
      :client_id => Config["client_id"],
      :redirect_uri => redirect_uri,
      :client_secret => Config["client_secret"],
      :code => auth_code
    }
    response = base_url['/oauth/access_token'].post_form(request_params).body
    params = Rack::Utils.parse_query(response)
    params['access_token']
  end
  
  def authorized_get(path, access_token)
    base_url[path].get(:access_token => access_token)
  end
  
  def base_url
    Config["facebook_uri"].to_uri
  end
end