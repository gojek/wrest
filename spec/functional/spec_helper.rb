require File.expand_path(File.dirname(__FILE__) + "/../../lib/wrest")
require "#{Wrest::Root}/wrest/curl"
require 'spec'

Wrest.logger = Logger.new(File.open("#{Wrest::Root}/../log/test.log", 'a'))

def ph(*args)
  puts *(["<pre>"] + args + ["</pre>"])
end