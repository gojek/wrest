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
    attr_reader :callback_hash

    def initialize(callable)
      if callable.is_a?(Hash)
        @callback_hash = Callback.ensure_values_are_collections(callable)
      elsif callable.is_a?(Proc)
        @callback_hash = {}
        callable.call(self)
      end
    end

    def merge(callback)
      merged_callback_hash = callback_hash.clone
      other_callback_hash = callback.callback_hash
      other_callback_hash.each do |code, callback_blocks|
        merged_callback_hash[code] ||= [] 
        merged_callback_hash[code] += callback_blocks
      end
      Callback.new(merged_callback_hash)
    end

    def execute(response)
      callback_hash.each do |code, callback_list|
        callback_list.each {|callback| callback.call(response)} if case code
        when Range
          code.include?(response.code.to_i)
        when Fixnum
          code == response.code.to_i
        end
      end
    end

    def on(code, &block)
      @callback_hash[code] ? @callback_hash[code] << block : @callback_hash[code] = [block]
    end

    {200 => "ok", 201 => "created", 202 => "accepted", 204 => "no_content", 301 => "moved_permanently", 302 => "found", 303 => "see_other", 304 => "not_modified",
      307 => "temporary_redirect", 400 => "bad_request", 401 => "unauthorized", 403 => "forbidden", 404 => "not_found", 405 => "method_not_allowed",
      406 => "not_acceptable", 422 => "unprocessable_entity", 500 => "internal_server_error"}.each do |code, method|
        method_name = "on_#{method}".to_sym
        define_method method_name do |&block|
          (@callback_hash[code] ? @callback_hash[code] << block : @callback_hash[code] = [block]) if block
        end
      end

    def self.ensure_values_are_collections(hash)
      result = {}
      hash.each do |code, block|
        result[code] = block.is_a?(Array) ? block : [block]
      end
      result
    end
  end
end
