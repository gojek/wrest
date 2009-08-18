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

response = 'http://twitter.com/statuses/public_timeline.json'.to_uri.get

puts "Code: #{response.code}"
puts "Message: #{response.message}"
puts "Headers: #{response.headers.inspect}"

puts

# How about a little Object goodness?
# Lets wrap every tweet in a Tweet class.
#
# Every Tweet contains the details of the twitter
# user that posted it. We'd like this data to
# also be encapsulated in a TwitterUser.

class TwitterUser
  # This will turn this class into a wrapper
  # for a hash map.
  #
  # All the keys in the hash are exposed as methods.
  include Wrest::Components::AttributesContainer

  # We'd prefer the user's profile url to be
  # a Wrest::Uri rather than a String, wouldn't we?
  #
  # Remember, enabling typecasting support _will_
  # slow down instance construction marginally, so turn it on
  # only if you need it.
  enable_typecasting_support

  typecast :url => lambda{|url| url.to_uri}
end

class Tweet
  include Wrest::Components::AttributesContainer

  # And the user embedded in every tweet should be
  # a TwitterUser...
  enable_typecasting_support

  typecast  :user => lambda{|user| TwitterUser.new(user) }
end

tweets = response.deserialise.collect do |tweet|
  Tweet.new(tweet)
end

user = tweets.first.user

puts user.name

# Just remember that not everyone on Twitter has a
# url. On the other hand, some have more than one.
# This is just a cute little example that deals with
# the simple case of a single url.
puts user.url.get.body
