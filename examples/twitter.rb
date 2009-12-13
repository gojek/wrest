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

# This example shows a more object oriented approach
# to accessing Twitter using Wrest.
# 
# Twitter is your twitter account. Every tweet is wrapped in
# an instance of Tweet. Every Tweet has one TwitterUser.

class Twitter  
  def initialize(options)
    @uri = "https://twitter.com".to_uri(options)
  end
  
  # which can be :friends, :user or :public
  # options[:query] can be things like since, since_id, count, etc.
  def timeline(which = :friends, options={})
    @uri["/statuses/#{which}_timeline.json"].get(options).deserialise.collect{|tweet| Tweet.new(tweet)}
  end
  
  def post(text)
    Tweet.new @uri['/statuses/update.json'].post('', {'User-Agent' => "Wrest/#{Wrest::VERSION::STRING}"}, :status => text).deserialise
  end  
end

class TwitterUser
  # This will turn this class into a wrapper
  # for the deserialised data from a response.
  #
  # All the keys in the hash are exposed as methods.
  include Wrest::Components::Container

  # We'd prefer the user's profile url to be
  # a Wrest::Uri rather than a String, wouldn't we?
  #
  # Remember, using typecasting _will_
  # slow down instance construction marginally, so turn it on
  # only if you need it.
  typecast :url => lambda{|url| url.to_uri}
end

class Tweet
  include Wrest::Components::Container

  typecast  :user => lambda{|user| TwitterUser.new(user) }
end


twitter = Twitter.new(:username => 'ponnappa', :password => 'ha!likeImchecking*that*in')

pp twitter.post("This tweet via the Twitter example in #wrest #{Wrest::VERSION::STRING}, http://github.com/kaiwren/wrest")

puts '', '*'*70, ''

tweets = twitter.timeline(:friends, :since_id => 20751449)

# Print the name of the first user in my timeline.
puts tweets.first.user.name

puts '', '*'*70, ''

# Just remember that not everyone on Twitter has a
# url. On the other hand, some have more than one.
# This is just a cute little example that deals with
# the simple case of a single url.
puts tweets.first.user.url.get.body