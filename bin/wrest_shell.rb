puts "Ruby #{RUBY_VERSION}, #{RUBY_RELEASE_DATE}, #{RUBY_PLATFORM}"

entry_point = "#{File.dirname(__FILE__)}/../lib/wrest.rb"
version = "#{File.dirname(__FILE__)}/../lib/wrest/version"

irb = RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'irb.bat' : 'irb'

require 'optparse'
options = { :irb => irb }
OptionParser.new do |opt|
  opt.banner = "Usage: console [options]"
  opt.on("--irb=[#{irb}]", 'Invoke a different irb.') { |v| options[:irb] = v }
  opt.parse!(ARGV)
end

libs =  " -r irb/completion"
libs << " -r #{entry_point}"

require version
puts "Loading Wrest #{Wrest::VERSION::STRING}"
exec "#{options[:irb]} #{libs} --simple-prompt"