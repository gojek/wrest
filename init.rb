require 'rubygems'
require 'net/http'
require 'net/https'
require 'forwardable'
require 'date'
require 'cgi'
require 'base64'
require 'logger'

WREST_ROOT = File.dirname(__FILE__)

module Wrest
  def self.logger=(logger)
    @logger = logger
  end
  
  def self.logger
    @logger
  end
end

Wrest.logger = Logger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG

["/lib/wrest/core_ext/*.rb", "/lib/wrest/*.rb"].each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}
