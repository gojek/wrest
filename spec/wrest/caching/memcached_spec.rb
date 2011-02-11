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
