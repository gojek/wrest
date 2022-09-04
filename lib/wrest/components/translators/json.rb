# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Components
    module Translators
      module Json
        module_function

        def deserialise(response, _options = {})
          ActiveSupport::JSON.decode(response.body)
        end

        def deserialize(response, options = {})
          deserialise(response, options)
        end

        def serialise(hash, options = {})
          hash.to_json(options)
        end

        def serialize(hash, options = {})
          serialise(hash, options)
        end
      end
    end
  end
end
