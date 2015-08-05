# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


module Wrest
  module AsyncRequest
    # Loads Wrest eventmachine backend alongwith eventmachine gem
    def self.enable_em
      require "wrest/async_request/event_machine_backend"
    end

    # Assign default backend to be used for asynchronous request. Default is to use threads
    def self.default_backend=(backend)
      @default_backend = backend
    end

    # Assign default backend for asynchronous request to using eventmachine. 
    def self.default_to_em!
      self.enable_em
      self.default_backend = Wrest::AsyncRequest::EventMachineBackend.new
    end

    # Assign default backend for asynchronous request to using threads. 
    def self.default_to_threads!(number_of_threads = 5)
      self.default_backend = Wrest::AsyncRequest::ThreadBackend.new(number_of_threads)
    end

    # Returns the default backend, which is the ThreadBackend
    def self.default_backend
      @default_backend || default_to_threads!
    end
    
    # Uses Thread#join to wait until all background requests
    # are completed.
    #
    # Use this as the last instruction in a script to prevent it from
    # exiting before background threads have completed running.
    #
    # Needs Wrest.default_backend to be an instance of ThreadBackend.
    def self.wait_for_thread_pool!
      default_backend.wait_for_thread_pool!
    end
  end
end
