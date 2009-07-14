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

class Delicious
  def initialize(options)
    @uri = "https://api.del.icio.us/v1".to_uri(options)
  end
  
  def bookmarks(options = {})
    @uri['/posts/get'].get(options)
  end
  
  def recent(options = {})
    @uri['/posts/recent'].get(options)
  end
end

account = Delicious.new :username => 'kaiwren', :password => 'fupupp1es'

pp account.bookmarks(:tag => 'rails', :dt => '20090712').deserialise

pp recently_saved_uris = account.recent(:tag => 'ruby').deserialise["posts"]["post"].collect{|bookmark| bookmark['href']}