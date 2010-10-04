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

group :multipart_support do
  gem 'multipart-post', '~> 1.0'
end

group :libcurl_support do
  # 1.8.7, 1.9.2, rbx
  platforms :ruby do
    gem 'patron', '~> 0.4.9'
  end
end

group :fast_xml_deserialisation_nokogiri do
  gem 'nokogiri', '~> 1.4.3.1'
end

group :fast_xml_deserialisation_ruby_libxml do
  platforms :ruby do
    gem 'libxml-ruby', '~> 1.1.4'
  end
end

group :fast_xml_deserialisation_rexml do
  platforms :jruby do
    gem 'jrexml', '~> 0.5.3'
  end
end

group :test do
  gem 'rspec', '~> 2.0.0.beta.22'
  gem 'sinatra', '~> 1.0.0'
end