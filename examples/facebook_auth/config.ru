$:.unshift File.dirname(__FILE__) + "/lib/"
require 'facebook_auth'
# use Rack::Static, :urls => ["/images", "/javascript", "/yql"], :root => "public"
enable  :sessions

run FacebookAuth