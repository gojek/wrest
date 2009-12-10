# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


module Wrest
  module Components
    # Contains strategies/lambdas which know how to deserialise
    # different content types.
    module Translators
      # Loads the appropriate desirialisation strategy based on
      # the content type
      def self.lookup(content_type)
        translator = CONTENT_TYPES[content_type]
        translator || (raise Wrest::Exceptions::UnsupportedContentType.new("Unsupported content type #{content_type}"))
      end
    end
  end
end

require "#{Wrest::Root}/wrest/components/translators/xml"
require "#{Wrest::Root}/wrest/components/translators/json"
require "#{Wrest::Root}/wrest/components/translators/content_types"
