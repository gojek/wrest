require 'rubygems'
require 'net/http'

WREST_ROOT = File.dirname(__FILE__)

["/lib/**/*.rb"].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}
