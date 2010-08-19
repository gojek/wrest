require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")
require "#{Wrest::Root}/wrest/curl" unless RUBY_PLATFORM =~ /java/
require 'rspec'

['/custom_matchers/**/*.rb'].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}

Wrest.logger = Logger.new(File.open("#{Wrest::Root}/../log/test.log", 'a'))

def p(*args)
 # super *(args << caller[0])
 super *(args << '<br/>')
 # super *args
end

def puts(*args)
 # super *(args << caller[0])
 super *(['<pre>'] + args + ['</pre>'])
 # super *args
end

def ph(*args)
  puts *(["<pre>"] + args + ["</pre>"])
end

RSpec.configure do |config|
  config.include(CustomMatchers)
  config.filter_run :functional => ENV["wrest_functional_spec"] == "true" || nil
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
