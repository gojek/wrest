# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  # Contains functionality that is independent of
  # the underlying HTTP libs
  module HttpShared
  end
end

require "#{Wrest::Root}/wrest/http_shared/headers"
require "#{Wrest::Root}/wrest/http_shared/standard_headers"
require "#{Wrest::Root}/wrest/http_shared/standard_tokens"

# Set up a shorter convenience API for constants
Wrest::H = Wrest::HttpShared::StandardHeaders
Wrest::T = Wrest::HttpShared::StandardTokens
