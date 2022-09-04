# frozen_string_literal: true

source 'http://rubygems.org'

gem 'rake', '~> 13.0'
gem 'rdoc', '~> 6.4'
gem 'rspec-collection_matchers', '~> 1.1'
gem 'simplecov', platforms: :mri_19

gem 'rexml' if RUBY_VERSION.start_with?('3.')

group :multipart_support do
  gem 'multipart-post', '~> 2'
end

group :nokogiri do
  gem 'nokogiri', '~> 1'
end

group :libxml do
  platforms :ruby do
    gem 'libxml-ruby', '~> 3.2.3' unless Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/
  end
end

group :memcached_support do
  gem 'dalli', '~> 2'
end

group :redis_support do
  gem 'redis', '~> 3'
end

group :eventmachine_support do
  gem 'eventmachine', '~> 1.0.7'
end

gemspec
