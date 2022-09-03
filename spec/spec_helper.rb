# frozen_string_literal: true
begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
  puts 'Simplecov is not available, no coverage report will be generated'
end

require 'wrest'

Dir[File.join("#{__dir__}", 'support', '*.rb')].map { |f| require f }

Wrest.logger = Logger.new(File.open("#{Wrest::Root}/../log/test.log", 'a'))

RSpec.configure do |config|
  config.include(Factories)
  if ENV['wrest_functional_spec'] == 'true'
    config.filter_run functional: true
  else
    config.filter_run_excluding functional: true
  end
end
