# frozen_string_literal: true

$:.unshift(File.join(__dir__, 'lib'))
require 'sample_app'
# use Rack::Static, :urls => ["/images", "/javascript", "/yql"], :root => "public"
enable  :sessions
set :root, File.join(__dir__, 'lib')
run SampleApp::Application
