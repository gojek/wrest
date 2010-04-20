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

require "#{Wrest::Root}/wrest/native/connection_factory"
require "#{Wrest::Root}/wrest/native/response"
require "#{Wrest::Root}/wrest/native/redirection"
require "#{Wrest::Root}/wrest/native/request"
require "#{Wrest::Root}/wrest/native/get"
require "#{Wrest::Root}/wrest/native/put"
require "#{Wrest::Root}/wrest/native/post"
require "#{Wrest::Root}/wrest/native/delete"
require "#{Wrest::Root}/wrest/native/options"
require "#{Wrest::Root}/wrest/native/session"

# default to using Native libs
Wrest::Http = Wrest::Native