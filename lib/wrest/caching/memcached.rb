# frozen_string_literal: true
begin
  gem 'dalli', '~> 2'
rescue Gem::LoadError => e
  Wrest.logger.debug 'Dalli ~> 2 not found. The Dalli gem is necessary to use the memcached caching back-end.'
  raise e
end

require 'dalli'

module Wrest::Caching
  class Memcached
    def initialize(server_urls = nil, options = {})
      @memcached = Dalli::Client.new(server_urls, options)
    end

    def [](key)
      @memcached.get(key)
    end

    def []=(key, value)
      @memcached.set(key, value)
    end

    # should be compatible with Hash - return value of the deleted element.
    def delete(key)
      value = self[key]

      @memcached.delete key

      value
    end
  end
end
