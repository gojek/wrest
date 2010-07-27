require File.expand_path(File.dirname(__FILE__) + "/../../lib/wrest")
require 'rspec'

Wrest.logger = Logger.new(File.open("#{Wrest::Root}/../log/test.log", 'a'))

def ph(*args)
  puts *(["<pre>"] + args + ["</pre>"])
end
