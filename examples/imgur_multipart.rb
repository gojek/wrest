# Copyright 2009 - 2010 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'pp'
require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")

# See http://code.google.com/p/imgur-api
imgur_key = 'f6561f62e13422bb25a1e738e9927d3b' # use your own key, this one is fake
file_path = 'VoA10.png'

# Using the eminently sensible Base64 encoded imgur file upload API
pp 'http://imgur.com/api/upload.xml'.to_uri.post_form(:image => [IO.read(file_path)].pack('m'), :key => imgur_key).deserialise

# If an API requires multipart posts - like the Facebook API - you can do that too
require 'wrest/multipart'
File.open(file_path) do |file|
  pp 'http://imgur.com/api/upload.xml'.to_uri.post_multipart(:image => UploadIO.new(file, "image/png", file_path), :key => imgur_key).deserialise
end
