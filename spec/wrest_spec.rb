require "spec_helper"
require 'rspec'

describe Wrest do
  context "caching options", :functional => true do

    it "should use memached when always_cache_using_memcached is called" do
      Wrest.always_cache_using_memcached!
      Wrest.default_cachestore.should be_a(Wrest::Components::CacheStore::Memcached)

      Wrest.default_cachestore.should_receive(:[]=)
      "http://localhost:3000/cacheable/cant_be_validated/with_expires/300".to_uri.get
    end

    it "should use a Hash when always_cache_using_hash is called" do
      Wrest.always_cache_using_hash!
      Wrest.default_cachestore.should be_a(Hash)

      Wrest.default_cachestore.should_receive(:[]=)
      "http://localhost:3000/cacheable/cant_be_validated/with_expires/300".to_uri.get
    end
  end
end
