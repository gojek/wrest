# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'rubygems'
gem 'activesupport', '>= 2.3.5'

require 'net/http'
require 'net/https'
require 'forwardable'
require 'date'
require 'cgi'
require 'base64'
require 'logger'
require 'benchmark'
require 'active_support'


module Wrest
  Root = File.dirname(__FILE__)
  
  $:.unshift Root
  
  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  # Switch Wrest to using Net::HTTP.
  def self.use_native
    silence_warnings{ Wrest.const_set('Http', Wrest::Native) }
  end

  # Switch Wrest to using libcurl.
  def self.use_curl
    require "#{Wrest::Root}/wrest/curl"
    silence_warnings{ Wrest.const_set('Http', Wrest::Curl) }
  end
end

Wrest.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG

begin
  gem 'libxml-ruby', '>= 1.1.3'
  ActiveSupport::XmlMini.backend='LibXML'
rescue Gem::LoadError
  Wrest.logger.debug "Warning: LibXML >= 1.1.3 not found, attempting to use Nokogiri. To install LibXML run `(sudo) gem install libxml-ruby` (libxml-ruby is not available on JRuby)"
  begin
    gem 'nokogiri', '>= 1.3.3'
    ActiveSupport::XmlMini.backend='Nokogiri'
  rescue Gem::LoadError
    Wrest.logger.debug "Warning: Nokogiri >= 1.3.3 not found, falling back to #{ActiveSupport::XmlMini.backend} (which is probably significantly slower). To install Nokogiri run `(sudo) (jruby -S) gem install nokogiri`"
    if RUBY_PLATFORM =~ /java/
      begin
        gem 'jrexml', '>= 0.5.3'
        require 'jrexml'
        Wrest.logger.debug "Detected JRuby, JREXML loaded."
      rescue Gem::LoadError
        Wrest.logger.debug "Warning: Detected JRuby, but failed to load JREXML. JREXML offers *some* performance improvement when using REXML on JRuby. To install JREXML run `(sudo) jruby -S gem install jrexml`"
      end
    end
  end
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/wrest/core_ext/*.rb"].each { |file| require file }

# Load Wrest Core
require "#{Wrest::Root}/wrest/version"
require "#{Wrest::Root}/wrest/http_shared"
require "#{Wrest::Root}/wrest/native"

# Load Wrest Wrappers
require "#{Wrest::Root}/wrest/uri"
require "#{Wrest::Root}/wrest/uri_template"
require "#{Wrest::Root}/wrest/exceptions"
require "#{Wrest::Root}/wrest/components"

# Load Wrest::Resource
require "#{Wrest::Root}/wrest/resource"

# if (ENV['RAILS_ENV'] == 'test' || (Kernel.const_defined?(:RAILS_ENV) && (RAILS_ENV == 'test')))
#   require "#{Wrest::Root}/wrest/test"
# end
