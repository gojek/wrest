# frozen_string_literal: true
# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  # Contains all native protocol related classes such as
  # Get, Post, Request, Response etc. and uses the native
  # Ruby Net::HTTP libraries.
  #
  # Wrest::Http points to this module by default.
  module Native
    include Wrest::HttpShared
  end
end

require 'wrest/native/connection_factory'
require 'wrest/native/response'
require 'wrest/native/redirection'
require 'wrest/native/request'
require 'wrest/native/get'
require 'wrest/native/put'
require 'wrest/native/patch'
require 'wrest/native/post'
require 'wrest/native/delete'
require 'wrest/native/options'
require 'wrest/native/session'

# default to using Native libs
Wrest::Http = Wrest::Native
