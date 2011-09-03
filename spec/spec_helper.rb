require 'simplecov'
SimpleCov.start

require "wrest"
require "wrest/curl" unless RUBY_PLATFORM =~ /java/


Dir[File.join("#{File.expand_path(File.dirname(__FILE__))}", "support", "*.rb")].map {|f| require f}

Wrest.logger = Logger.new(File.open("#{Wrest::Root}/../log/test.log", 'a'))

RSpec.configure do |config|
  config.include(Factories)
  config.filter_run :functional => ENV["wrest_functional_spec"] == "true" || nil
end