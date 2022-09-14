# frozen_string_literal: true

require 'rubygems'

# Set up gems listed in the Gemfile.
gemfile = File.expand_path('../Gemfile', __dir__)

if File.exist?(gemfile)
  begin
    ENV['BUNDLE_GEMFILE'] = gemfile
    require 'bundler'
    require 'json'
    Bundler.setup
  rescue Bundler::GemNotFound => e
    warn e.message
    warn 'Try running `bundle install`.'
    exit!
  end
end

Bundler.require(:default)
