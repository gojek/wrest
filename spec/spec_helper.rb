require 'rubygems'
require 'spec'
require File.expand_path(File.dirname(__FILE__) + "/../init.rb")

["/custom_matchers/**/*.rb"].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}

Spec::Runner.configure do |config|
  # config.include(CustomMatchers)
end