require File.expand_path(File.dirname(__FILE__) + "/../init.rb")
require 'spec'

["/custom_matchers/**/*.rb"].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}

Spec::Runner.configure do |config|
  config.include(CustomMatchers)
end