# frozen_string_literal: true

puts "Ruby #{RUBY_VERSION}, #{RUBY_RELEASE_DATE}, #{RUBY_PLATFORM}"

entry_point = File.join(__dir__, '..', 'lib', 'wrest.rb')
version_file = File.expand_path(File.join(__dir__, '..', 'lib', 'wrest', 'version.rb'))

irb = RUBY_PLATFORM =~ /(:?mswin|mingw)/ ? 'irb.bat' : 'irb'

require 'optparse'
options = { irb: irb }
OptionParser.new do |opt|
  opt.banner = 'Usage: console [options]'
  opt.on("--irb=[#{irb}]", 'Invoke a different irb.') { |v| options[:irb] = v }
  opt.parse!(ARGV)
end

libs = ' -r irb/completion ' \
       "-r #{entry_point}"

require version_file
puts "Loading Wrest #{Wrest::VERSION}"
exec "#{options[:irb]} #{libs} --simple-prompt"
