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

class Twitter  
  def initialize(options)
    @uri = "https://twitter.com".to_uri(options)
  end
  
  # which can be :friends, :user or :public
  # options[:query] can be things like since, since_id, count, etc.
  def timeline(which = :friends, options={})
    @uri["/statuses/#{which}_timeline.json"].get(options)
  end
  
  def post(text)
    @uri['/statuses/update.json'].post('', {'User-Agent' => "Wrest/#{Wrest::VERSION::STRING}"}, {:status => text})
  end
end

twitter = Twitter.new(:username => 'ponnappa', :password => 'ha!likeImchecking*that*in')

# pp twitter.timeline.deserialise
# pp twitter.timeline(:friends, :since_id => 20751449).deserialise
pp twitter.post("This tweet via the Twitter example in #wrest #{Wrest::VERSION::STRING}, http://github.com/kaiwren/wrest").deserialise