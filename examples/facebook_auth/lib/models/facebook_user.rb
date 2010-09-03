class FacebookUser
  def initialize(access_token)
    @access_token = access_token
  end
  
  def profile
    client  = FacebookClient.new
    FacebookProfile.new(client.authorized_get("/me", @access_token).deserialise)
  end
  
  def authenticated?
    !@access_token.blank?
  end
end