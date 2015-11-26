require "spec_helper"
require 'rspec'

Wrest::Caching.enable_redis

describe Wrest::Caching do
  context "functional", :functional => true do
    before :each do
      @redis = Wrest::Caching::Redis.new
      @redis["abc"]="xyz"
    end

    context "initialization defaults" do
      it "should always default the options to an empty hash" do
        expect(Redis).to receive(:new).with({})
        client = Wrest::Caching::Redis.new
      end
      
      it "should pass through options received to redis" do
        expect(Redis).to receive(:new).with(:host => "10.0.1.1", :port => 6380, :db => 15)
        client = Wrest::Caching::Redis.new(:host => "10.0.1.1", :port => 6380, :db => 15)
      end
    end

    it "should know how to retrieve a cache entry" do
      expect(@redis["abc"]).to eq("xyz")
    end

    it 'should unmarshall the value when retrieved a cache entry' do
      ok_response = 'http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_304/1000'.to_uri.get
      @redis['example-123'] = ok_response

      expect(@redis['example-123']).to eq(ok_response)
    end

    it "should know how to update a cache entry" do
      @redis["abc"] = "123"
      expect(@redis["abc"]).to eq("123")
    end

    it "should know how to delete a cache entry" do
      @redis.delete("abc").should == "xyz"
      expect(@redis["abc"]).to eq(nil)
    end
  end
end

