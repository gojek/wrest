# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.


module Wrest
  module AsyncRequest
    def self.enable_em
      require "#{Wrest::Root}/wrest/async_request/event_machine_backend"
    end

    def self.default_backend=(backend)
      @default_backend = backend
    end

    def self.default_to_em!
      self.enable_em
      self.default_backend = Wrest::AsyncRequest::EventMachineBackend.new
    end

    def self.default_to_threads!
      self.default_backend = Wrest::AsyncRequest::ThreadBackend.new
    end

    def self.default_backend
      @default_backend
    end
  end
end
