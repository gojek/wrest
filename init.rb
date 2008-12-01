require 'rubygems'
require 'net/http'
require 'net/https'
WREST_ROOT = File.dirname(__FILE__)

["/lib/core_ext/*.rb", "/lib/wrest/*.rb"].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}
