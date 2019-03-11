# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Native
  module ConnectionFactory
    def create_connection(options = {:timeout => 60, :open_timeout => 60, :verify_mode => OpenSSL::SSL::VERIFY_NONE})
      options[:timeout] ||= 60
      options[:open_timeout] ||= 60
      connection = Net::HTTP.new(self.host, self.port)
      connection.read_timeout = options[:timeout]
      connection.open_timeout = options[:open_timeout]
      if self.https?
        connection.use_ssl     = true
        connection.verify_mode = options[:verify_mode] ? options[:verify_mode] : OpenSSL::SSL::VERIFY_PEER 
        connection.ca_path = options[:ca_path] if options[:ca_path]
      end
      connection
    end
  end
end
