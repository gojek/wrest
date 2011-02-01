# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
#
module Wrest
  class Callback
    def initialize(callbacks={})
      @callbacks = callbacks.clone
      @callbacks.each do |code, block|
        @callbacks[code] = [block] unless block.is_a?(Array)
      end
    end

    def merge(block)
      callback = Callback.new(@callbacks) 
      block.call(callback)
      callback
    end

    def execute(response)
      @callbacks.each do |code, callback_list|
        callback_list.each {|callback| callback.call(response)} if code == response.code.to_i
      end
    end

    {200 => "ok", 201 => "created", 202 => "accepted", 204 => "no_content", 301 => "moved_permanently", 302 => "found", 303 => "see_other", 304 => "not_modified",
      307 => "temporary_redirect", 400 => "bad_request", 401 => "unauthorized", 403 => "forbidden", 404 => "not_found", 405 => "method_not_allowed",
      406 => "not_acceptable", 422 => "unprocessable_entity", 500 => "internal_server_error"}.each do |code, method|
        method_name = "on_#{method}".to_sym
        define_method method_name do |&block|
          (@callbacks[code] ? @callbacks[code] << block : @callbacks[code] = [block]) if block
        end
      end
  end
end
