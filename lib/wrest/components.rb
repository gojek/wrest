# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest #:nodoc:
  # A component is a building block that can
  # be used while building an object oriented wrapper
  # around a REST service
  module Components
  end
end

require "#{WREST_ROOT}/wrest/components/typecast_helpers"
require "#{WREST_ROOT}/wrest/components/attributes_container"
require "#{WREST_ROOT}/wrest/components/mutators"