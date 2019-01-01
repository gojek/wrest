source "https://rubygems.org"

gem 'rake', '~> 10.0'
gem 'rspec-collection_matchers', '~> 1.1'
gem 'rdoc', '~> 4.2'
gem 'simplecov', :platforms => :mri_19

group :multipart_support do
  gem 'multipart-post', '~> 2.0'
end

group :nokogiri do
  gem 'nokogiri', '~> 1.0'
end

group :libxml do
  platforms :ruby do
    gem 'libxml-ruby', '~> 2.8.0' unless Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/
  end
end

group :memcached_support do
  gem 'dalli', '~> 2.0'
end

group :redis_support do
  gem 'redis', '~> 3.0'
end

group :eventmachine_support do
  gem 'eventmachine', '~> 1.0.7'
end

gemspec
