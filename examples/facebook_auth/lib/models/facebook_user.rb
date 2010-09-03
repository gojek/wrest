class FacebookUser
  def initialize(access_token)
    @access_token = access_token
  end
  
  def profile
    client  = FacebookClient.new
    FacebookProfile.new(ActiveSupport::JSON.decode(client.authorized_get("/me", @access_token).body))
  end
  
  def authenticated?
    !@access_token.blank?
  end
end