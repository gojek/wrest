require 'dalli'

module Wrest
  module Components
    module CacheStore
      class Memcached < Dalli::Client
        # Dalli will transparently serialize and de-serialize all objects using Marshal. 
        alias_method :[], :get
        alias_method :[]=, :set
      end
    end
  end
end
