# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest
  module CoreExt #:nodoc:
    module String #:nodoc:
      # Makes it easier to build other objects from a String
      # This module is opt-out - if you don't want the to_uri
      # convenience method on String, set the NoStringExtensions
      # constant on the Wrest module before requiring wrest.
      #
      #   module Wrest
      #     NoStringExtensions = true
      #   end
      #   require 'wrest'
      module Conversions

        # A convenience method equivalent to Wrest::Uri.new(string)
        def to_uri(options = {})
          Wrest::Uri.new(self.strip, options)
        end
      end
    end
  end
end
