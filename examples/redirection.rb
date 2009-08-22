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

# google.com redirects to www.google.com so this is live test for redirection
pp 'http://google.com'.to_uri.get.body

puts '', '*'*70, ''

# Do a get with auto follow redirects turned off
pp 'http://google.com'.to_uri(:follow_redirects => false).get.body

puts '', '*'*70, ''

# Do a get with auto follow redirects limited, causing an exception.
'http://google.com'.to_uri(:follow_redirects_limit => 1).get.body