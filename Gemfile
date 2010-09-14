source "http://rubygems.org"

gem 'activesupport', '~> 3.0.0'
gem 'builder', '~> 2.1.2'
gem 'i18n', '~> 0.4.1'
gem 'tzinfo', '~> 0.3.23'

platforms :jruby do
  gem 'json-jruby', '~> 1.4.3.1'
end

platforms :ruby do
  gem 'json', '~> 1.4.6'
end

group :test do
  gem 'rspec', '~> 2.0.0.beta.20'
  gem 'nokogiri', '~> 1.4.3.1'
  gem 'multipart-post', '~> 1.0'
  platforms :ruby do
    gem 'patron', '~> 0.4.8'
  end
  platforms :jruby do
    gem 'jrexml', '~> 0.5.3'
  end
end