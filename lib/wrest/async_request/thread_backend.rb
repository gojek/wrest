# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module AsyncRequest
    # Uses a pool of Threads to make requests.
    # Only recommended for production use on JRuby.
    class ThreadBackend
      attr_reader :thread_pool

      def initialize(number_of_threads = 5)
        @thread_pool = ThreadPool.new(number_of_threads)
      end

      def execute(request)
        @thread_pool.execute_eventually(request)
      end

      # Uses Thread#join to wait until all
      # background requests are completed.
      def wait_for_thread_pool!
        @thread_pool.join_pool_threads!
      end
    end
  end
end
