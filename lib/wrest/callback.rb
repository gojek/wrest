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

    def on_ok(&block)
      (@callbacks[200] ? @callbacks[200] << block : @callbacks[200] = [block]) if block
    end
  end
end
