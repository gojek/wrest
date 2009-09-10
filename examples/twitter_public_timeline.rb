# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")
require 'pp'

Wrest.logger = Logger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG  # Set this to Logger::INFO or higher to disable request logging


# This is a basic example demonstrating GET and json deserialisation.

response = 'http://twitter.com/statuses/public_timeline.json'.to_uri.get(:timeout => 5)

puts "Code: #{response.code}"
puts "Message: #{response.message}"
puts "Headers: #{response.headers.inspect}"
puts "Body: #{response.body.inspect}"
puts "Deserialised: #{response.deserialise.inspect}"