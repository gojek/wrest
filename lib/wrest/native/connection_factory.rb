# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Native
  module ConnectionFactory
    def create_connection(timeout = 60)
      timeout ||= 60
      connection = Net::HTTP.new(self.host, self.port)
      connection.read_timeout = timeout
      if self.https?
        connection.use_ssl     = true
        connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      connection
    end
  end
end