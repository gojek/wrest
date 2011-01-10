require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")
require "#{Wrest::Root}/wrest/curl" unless RUBY_PLATFORM =~ /java/
require 'rspec'

['/custom_matchers/**/*.rb'].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}

Wrest.logger = Logger.new(File.open("#{Wrest::Root}/../log/test.log", 'a'))

def putsh(*args)
  puts *(["<pre>"] + args + ["</pre>"])
end

RSpec.configure do |config|
  config.include(CustomMatchers)
  config.filter_run :functional => ENV["wrest_functional_spec"] == "true" || nil
end

    
def build_ordered_hash(tuples)
  ActiveSupport::OrderedHash.new.tap do |hash|
    tuples.each do |key, value|
      hash[key] = value
    end
  end
end

def build_ok_response(body = '', headers = {})
  build_response('200','OK',body, headers)
end

def build_response(code,message = '', body = '', headers = {})
  mock(Net::HTTPOK).tap do |response|
    response.stub!(:code).and_return(code)
    response.stub!(:message).and_return(message)
    response.stub!(:body).and_return(body)
    response.stub!(:to_hash).and_return(headers)
    headers.each{|k,v|
      response.stub!('[]').with(k).and_return(v)
    }
  end
end

def format_date_in_rfc822_format(date)
  date.in_time_zone('UTC').strftime('%a, %d %b %Y %H:%M:%S %Z')
end

def xml_backends
  backends = ['Nokogiri','REXML']
  backends << 'LibXML' unless (RUBY_PLATFORM =~ /java/ || (Object.const_defined?('RUBY_ENGINE') && RUBY_ENGINE =~ /rbx/))
  backends
end

def cacheable_headers
  half_hour_after = (Time.now + (60*30)).httpdate
  ten_mins_early  = (Time.now - (10*30)).httpdate

  # All responses in the caching block returns a cacheable response by default
  headers         = {"Date" => Time.now.httpdate, "Expires" => half_hour_after, "Age" => 0, "Last-Modified" => ten_mins_early}
  headers
end
