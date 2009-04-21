require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")
require 'spec'

["/custom_matchers/**/*.rb"].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}

Wrest.logger = Logger.new(File.open("#{WREST_ROOT}/../log/test.log", 'a'))

def p(*args)
 # super *(args << caller[0])
 super *(args << '<br>')
end

Spec::Runner.configure do |config|
  config.include(CustomMatchers)
end