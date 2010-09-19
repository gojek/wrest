$:.unshift File.dirname(__FILE__) + "/lib/"
require 'sample_app'
# use Rack::Static, :urls => ["/images", "/javascript", "/yql"], :root => "public"
enable  :sessions
set :root, File.join(File.dirname(__FILE__), 'lib')
run SampleApp::Application