source "http://rubygems.org"

group :multipart_support do
  gem 'multipart-post', '~> 1.0'
end

group :libcurl_support do
  # 1.8.7, 1.9.2, rbx
  platforms :ruby do
    gem 'patron', '~> 0.4.11'
  end
end

group :fast_xml_deserialisation_nokogiri do
  gem 'nokogiri', '~> 1.4.4'
end

group :fast_xml_deserialisation_ruby_libxml do
  platforms :ruby do
    gem 'libxml-ruby', '>= 1.1.4' unless Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/
  end
end
 
group :fast_xml_deserialisation_rexml do
  platforms :jruby do
    gem 'jrexml', '~> 0.5.3'
  end
end

group :memcached_support do
  gem 'dalli', '~> 1.0.1'
end

group :eventmachine_support do
  gem 'eventmachine', '~> 0.12.10'
end

gemspec
