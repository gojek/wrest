# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

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

source_dirs = ["/wrest/core_ext/*.rb", "/wrest/*.rb"]

source_dirs.each{|directory|
  Dir["#{File.expand_path(File.dirname(__FILE__) + directory)}"].each { |file|
    require file
  }
}