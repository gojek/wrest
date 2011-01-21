require 'dalli'

module Wrest::Components::CacheStore
  class Memcached

    def initialize(servers='', options={})
      @memcached = Dalli::Client.new
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
