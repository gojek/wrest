require File.expand_path(File.dirname(__FILE__) + "/../../lib/wrest")
require 'spec'

Wrest.logger = Logger.new(File.open("#{WREST_ROOT}/../log/test.log", 'a'))

def ph(*args)
  puts *(["<pre>"] + args + ["</pre>"])
end