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

# Optionally uncomment the following line to use the significantly faster libcurl library.
# This uses the patron gem - (sudo) gem install patron
# IMPORTANT: Libcurl support is currently in alpha and is both incomplete and unstable!
# Wrest.use_curl

# This is a basic example demonstrating GET and json deserialisation. The timeout field is optional, of course (it defaults to 60), but you can reduce it to a low number like 1 to force the request to timeout.

response = 'http://twitter.com/statuses/public_timeline.json'.to_uri(:timeout => 5).get

puts "Code: #{response.code}"
puts "Message: #{response.message}"
puts "Headers: #{response.headers.inspect}"
puts
puts "Deserialised Body: #{response.deserialise.inspect}"
puts '*' * 50
puts '*' * 50
puts "Body: #{response.body.inspect}"