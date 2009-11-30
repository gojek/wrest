# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details
  # session :off
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  def headers
    headers = request.headers.inject({}){|acc, tuple| acc[tuple.first] = tuple.last if tuple.last.is_a?(String); acc }
    render :json => headers
  end
  
  def no_body
    head :created
  end
  
  def nothing
    render :nothing => true
  end
end
