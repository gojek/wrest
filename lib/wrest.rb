# frozen_string_literal: true

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
require 'concurrent'
require 'nokogiri'
require 'json'

module Wrest
  Root = File.dirname(__FILE__)

  $LOAD_PATH.unshift Root

  def self.logger=(logger)
    @logger = logger
  end

  def self.logger
    @logger
  end

  def self.enable_evented_requests!
    require 'wrest/event_machine_backend'
  end

  # Switch Wrest to using Net::HTTP.
  def self.use_native!
    old_verbose = $VERBOSE
    $VERBOSE = nil
    Wrest.const_set('Http', Wrest::Native)
  ensure
    $VERBOSE = old_verbose
  end
end

Wrest.logger = Logger.new($stdout)
Wrest.logger.level = Logger::DEBUG

require 'wrest/utils'
require 'wrest/core_ext/string'
require 'wrest/hash_with_indifferent_access'
require 'wrest/hash_with_case_insensitive_access'

# Load Wrest Core
require 'wrest/version'
require 'wrest/cache_proxy'
require 'wrest/http_shared'
require 'wrest/http_codes'
require 'wrest/callback'
require 'wrest/native'

require 'wrest/async_request/thread_pool'
require 'wrest/async_request/thread_backend'
require 'wrest/async_request'

require 'wrest/caching'

# Load Wrest Wrappers
require 'wrest/uri/builders'
require 'wrest/uri'
require 'wrest/uri_template'
require 'wrest/exceptions'
require 'wrest/components'
