# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

gem 'patron', '>=0.4.4'
require 'patron'

module Wrest #:nodoc:

  # Contains all HTTP protocol related classes such as
  # Get, Post, Request, Response etc. and uses Curl for
  # better performance, but works only on CRuby and only on a *nix OS.
  #
  # This functionality is under development and the Wrest API
  # may not cover using it fully.
  #
  # Note:
  # * The Curl based APIs do *not* support the HTTP options verb.
  module Curl
    include Wrest::HttpShared
  end
end

module Patron
  class Session
    public :handle_request
  end
end

require "#{Wrest::Root}/wrest/curl/response"
require "#{Wrest::Root}/wrest/curl/request"
require "#{Wrest::Root}/wrest/curl/get"
require "#{Wrest::Root}/wrest/curl/put"
require "#{Wrest::Root}/wrest/curl/post"
require "#{Wrest::Root}/wrest/curl/delete"
require "#{Wrest::Root}/wrest/curl/options"
# require "#{Wrest::Root}/wrest/curl/session"