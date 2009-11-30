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
include Wrest


# This is a basic example demonstrating using keep-alive connections.
# Observe the requests logs - they will look something like this:
# --> (GET 12207030 12546830) http://github.com:80/api/v1/json/kaiwren
#
# The second number after the GET is a hash identifying the connection used.
# You will notice that all requests have the same hash therefore use the same connection.

Http::Session.new('http://github.com/api/v1/json') do |s|
  puts "Response Connection Header - a response token of 'Keep-Alive' indicates that the server has created a keep-alive connection"
  puts
  puts s.get('/kaiwren')['Connection']
  puts s.get('/niranjan')['Connection']
  
  puts
  puts '*' * 10
  puts
  
  pp s.get('/kaiwren').deserialise
  pp s.get('/niranjan').deserialise
end