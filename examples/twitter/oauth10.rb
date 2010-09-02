require 'rubygems'
require 'rspec'

class OAuth10
  def initialize(options = {})
    @request_token_url = options[:request_token_url]
    @user_authorization_url = options[:request_token_url]
    @access_token_url = options[:request_token_url]
  end
end