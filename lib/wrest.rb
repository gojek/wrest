# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'rubygems'
gem 'activesupport', '~> 3.0'

require 'net/http'
require 'net/https'
require 'forwardable'
require 'date'
require 'cgi'
require 'base64'
require 'logger'
require 'benchmark'
require 'active_support'
require 'active_support/core_ext/string'
require 'active_support/core_ext/hash'
require 'active_support/core_ext/module'
require 'active_support/core_ext/object'

module Wrest
  Root = File.dirname(__FILE__)
  
  $:.unshift Root
  
  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  def self.enable_evented_requests!
    require "#{Wrest::Root}/wrest/event_machine_backend"
  end

  # Switch Wrest to using Net::HTTP.
  def self.use_native!
    silence_warnings{ Wrest.const_set('Http', Wrest::Native) }
  end

  # Switch Wrest to using libcurl.
  def self.use_curl!
    require "#{Wrest::Root}/wrest/curl"
    silence_warnings{ Wrest.const_set('Http', Wrest::Curl) }
  end
end

Wrest.logger = ActiveSupport::BufferedLogger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG

gem('json', '~> 1.5')
ActiveSupport::JSON.backend = "JSONGem"

require "#{Wrest::Root}/wrest/core_ext/string"
require "#{Wrest::Root}/wrest/hash_with_case_insensitive_access"

# Load XmlMini Extensions
require "#{Wrest::Root}/wrest/xml_mini"

# Load Wrest Core
require "#{Wrest::Root}/wrest/version"
require "#{Wrest::Root}/wrest/cache_proxy"
require "#{Wrest::Root}/wrest/http_shared"
require "#{Wrest::Root}/wrest/http_codes"
require "#{Wrest::Root}/wrest/callback"
require "#{Wrest::Root}/wrest/native"

require "#{Wrest::Root}/wrest/async_request"
require "#{Wrest::Root}/wrest/async_request/thread_backend"
Wrest::AsyncRequest.default_to_threads!

require "#{Wrest::Root}/wrest/caching"

# Load Wrest Wrappers
require "#{Wrest::Root}/wrest/uri"
require "#{Wrest::Root}/wrest/uri_template"
require "#{Wrest::Root}/wrest/exceptions"
require "#{Wrest::Root}/wrest/components"

# Load Wrest::Resource
# require "#{Wrest::Root}/wrest/resource"

# if (ENV['RAILS_ENV'] == 'test' || (Kernel.const_defined?(:RAILS_ENV) && (RAILS_ENV == 'test')))
#   require "#{Wrest::Root}/wrest/test"
# end
