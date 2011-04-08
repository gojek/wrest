# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at native://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

begin
  gem 'eventmachine', '~> 0.12.10'
rescue Gem::LoadError => e
  Wrest.logger.debug "Eventmachine ~> 0.12.10 not found. Wrest uses Eventmachine to perform evented asynchronous requests"
  raise e
end

require 'eventmachine'

module Wrest
  module AsyncRequest
    class EventMachineBackend 
      def execute(request)
        EventMachine.run do
          request.invoke
          EventMachine.stop
        end
      end
    end
  end
end
