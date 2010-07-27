require File.expand_path(File.dirname(__FILE__) + "/../../lib/wrest")
require "#{Wrest::Root}/wrest/curl" unless RUBY_PLATFORM =~ /java/
require 'rspec'

['/../custom_matchers/**/*.rb'].each{|directory|
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

RSpec.configure do |config|
  config.include(CustomMatchers)
end

def build_ok_response(body = '')
  response = mock(Net::HTTPOK)
    response.stub!(:code).and_return('200')
    response.stub!(:message).and_return('OK')
    response.stub!(:body).and_return(body)
  response
end
