# (c) Copyright 2009 Sidu Ponnappa. All Rights Reserved. 

require 'rubygems'
require 'net/http'
require 'net/https'
require 'forwardable'
require 'date'
require 'cgi'
require 'base64'
require 'logger'
require 'benchmark'
require 'active_support'

::WREST_ROOT = File.dirname(__FILE__)

module ::Wrest
  def self.logger=(logger)
    @logger = logger
  end
  
  def self.logger
    @logger
  end
end

Wrest.logger = Logger.new(STDOUT)
Wrest.logger.level = Logger::INFO

source_dirs = ["/lib/wrest/core_ext/*.rb", "/lib/wrest/*.rb"]

source_dirs.each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}
