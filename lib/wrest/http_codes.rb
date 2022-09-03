# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  # Contains convenience methods to check HTTP response codes
  module HttpCodes
    def ok?
      code.to_i == 200
    end

    def created?
      code.to_i == 201
    end

    def accepted?
      code.to_i == 202
    end

    def no_content?
      code.to_i == 204
    end

    def moved_permanently?
      code.to_i == 301
    end

    def found?
      code.to_i == 302
    end

    def see_other?
      code.to_i == 303
    end

    def not_modified?
      code.to_i == 304
    end

    def temporary_redirect?
      code.to_i == 307
    end

    def bad_request?
      code.to_i == 400
    end

    def unauthorized?
      code.to_i == 401
    end

    def forbidden?
      code.to_i == 403
    end

    def not_found?
      code.to_i == 404
    end

    def method_not_allowed?
      code.to_i == 405
    end

    def not_acceptable?
      code.to_i == 406
    end

    def unprocessable_entity?
      code.to_i == 422
    end

    def internal_server_error?
      code.to_i == 500
    end
  end
end
