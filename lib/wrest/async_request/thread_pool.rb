# Copyright 2009-2015 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module AsyncRequest
    class ThreadPool
      def initialize(number_of_threads)
        @threads = []
        @number_of_threads = number_of_threads
        @queue = Queue.new
      end
      
      def execute_eventually(request)
        initialize_thread_pool if @threads.empty?
        @queue.push(request)
        nil
      end
      
      def join_pool_threads!
        @threads.each do |thread|
          thread.join if thread.alive?
        end
      end
      
      private
      def initialize_thread_pool
        halt_on_sigint
        halt_on_int
        main_thread = Thread.current
        @threads =  @number_of_threads.times.map do |i|
          Thread.new do |thread|
            while request = @queue.pop
              request.invoke
            end
          end
        end
      end
      
      def halt_on_sigint
        trap('SIGINT') do
          halt
        end
      end
    
      def halt_on_int
        trap('INT') do
          halt
        end
      end
    
      def halt
        unless @threads.empty?
          Wrest.logger.debug "Wrest: Shutting down ThreadPool..."
          @threads.each(&:terminate)
          Wrest.logger.debug "Wrest: Halted ThreadPool, continuing with shutdown."
        end
        Process.exit
      end
    end
  end
end
