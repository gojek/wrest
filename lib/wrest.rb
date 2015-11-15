# Copyright 2009 Sidu Ponnappa
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'net/http'
require 'net/https'
require 'forwardable'
require 'date'
require 'cgi'
require 'base64'
require 'logger'
require 'benchmark'
require 'multi_json'
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
    require "wrest/event_machine_backend"
  end

  # Switch Wrest to using Net::HTTP.
  def self.use_native!
    silence_warnings{ Wrest.const_set('Http', Wrest::Native) }
  end
end

Wrest.logger = ActiveSupport::Logger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG

require "wrest/core_ext/string"
require "wrest/hash_with_case_insensitive_access"

# Load XmlMini Extensions
require "wrest/xml_mini"

# Load Wrest Core
require "wrest/version"
require "wrest/cache_proxy"
require "wrest/http_shared"
require "wrest/http_codes"
require "wrest/callback"
require "wrest/native"

require "wrest/async_request/thread_pool"
require "wrest/async_request/thread_backend"
require "wrest/async_request"

require "wrest/caching"

# Load Wrest Wrappers
require "wrest/uri/builders"
require "wrest/uri"
require "wrest/uri_template"
require "wrest/exceptions"
require "wrest/components"

# Load Wrest::Resource
# require "wrest/resource"
