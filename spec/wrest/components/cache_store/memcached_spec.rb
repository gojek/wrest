require "spec_helper"
require 'rspec'

describe Wrest::Components::CacheStore::Memcached do
  context "functional", :functional => true do
    before :each do
      @memcached       = Wrest::Components::CacheStore::Memcached.new
      @memcached["abc"]="xyz"
    end

    it "should know how to retrieve a cache entry" do
      @memcached["abc"].should =="xyz"
    end

    it "should know how to update a cache entry" do
      @memcached["abc"] = "123"
      @memcached["abc"].should == "123"
    end

    it "should know how to delete a cache entry" do
      @memcached.delete("abc").should == "xyz"
      @memcached["abc"].should be_nil
    end
  end

end