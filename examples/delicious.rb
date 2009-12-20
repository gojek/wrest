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
# Wrest.use_curl

# This example demonstrates the usage of GET, POST, PUT and
# DELETE over HTTPS. Its also shows how Wrest::Uris can have
# paths extended making accessing an API easy as pie. 
#
# Do remember to change the username and password on line 47
# before running this example.
#
# API reference: http://delicious.com/help/api
class Delicious
  def initialize(options)
    @uri = "https://api.del.icio.us/v1/posts".to_uri(options)
  end
  
  def bookmarks(parameters = {})
    @uri['/get'].get(parameters)
  end
  
  def recent(parameters = {})
    @uri['/recent'].get(parameters)
  end
  
  def bookmark(parameters)
    @uri['/add'].post_form(parameters)
  end
  
  def delete(parameters)
    @uri['/delete'].delete(parameters)
  end
end

account = Delicious.new :username => 'kaiwren', :password => 'fupupp1es'

puts '*'*20 + "Creating bookmark tagged Rails" + '*'*20

pp account.bookmark(
    :url => 'http://blog.sidu.in/search/label/ruby',
    :description => 'The Ruby related posts on my blog!',
    :extended => "All posts tagged with 'ruby'",
    :tags => 'ruby hacking'
  ).deserialise
  
puts '*'*20 + "Listing bookmarks tagged Rails on a certain date" + '*'*20

pp account.bookmarks(:tag => 'rails', :dt => '20090712').deserialise

puts '*'*20 + "Listing recent bookmarks" + '*'*20

pp account.recent(:tag => 'ruby').deserialise["posts"]["post"].collect{|bookmark| bookmark['href']}

puts '*'*20 + "Deleting the bookmark we just created" + '*'*20

pp account.delete(:url => 'http://blog.sidu.in/search/label/ruby').deserialise

puts '*'*20 + "Listing recent bookmarks" + '*'*20

pp account.recent(:tag => 'ruby').deserialise["posts"]["post"].collect{|bookmark| bookmark['href']}