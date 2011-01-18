require 'dalli'

module Wrest
  module Components
    module CacheStore
      class Memcached < Dalli::Client
        alias_method :[], :get
        alias_method :[]=, :set
      end
    end
  end
end
