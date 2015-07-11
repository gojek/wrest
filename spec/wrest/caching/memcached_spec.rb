require "spec_helper"
require 'rspec'

Wrest::Caching.enable_memcached

describe Wrest::Caching do
  context "functional", :functional => true do
    before :each do
      @memcached = Wrest::Caching::Memcached.new
      @memcached["abc"]="xyz"
    end

    context "initialization defaults" do
      it "should always default the list of server urls to nil" do
        Dalli::Client.should_receive(:new).with(nil, {})
        client = Wrest::Caching::Memcached.new
      end
      it "should always default the options to an empty hash" do
        Dalli::Client.should_receive(:new).with(nil, {})
        client = Wrest::Caching::Memcached.new
      end
    end

    it "should know how to retrieve a cache entry" do
      expect(@memcached["abc"]).to eq("xyz")
    end

    it "should know how to update a cache entry" do
      @memcached["abc"] = "123"
      expect(@memcached["abc"]).to eq("123")
    end

    it "should know how to delete a cache entry" do
      @memcached.delete("abc").should == "xyz"
      expect(@memcached["abc"]).to eq(nil)
    end
  end

end
