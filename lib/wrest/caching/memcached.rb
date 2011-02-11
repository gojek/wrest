begin
  gem 'dalli', '~> 1.0.1'
rescue Gem::LoadError => e
  Wrest.logger.debug "Dalli ~> 1.0.1 not found. Dalli is necessary to use the memcached caching back-end. To install dalli run `(sudo) gem install dalli`."
  raise e
end

require 'dalli'

module Wrest::Caching
  class Memcached

    def initialize(server_urls=nil, options={})
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

      return value
    end
  end
end
