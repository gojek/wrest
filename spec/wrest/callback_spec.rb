require "spec_helper"
require "#{Wrest::Root}/wrest"

module Wrest
  describe Callback do
    let(:response_200){mock(Net::HTTPOK, :code => 200, :message => "OK", :body => '', :to_hash => {})}
    context "new" do
      context "ensure_values_are_collections" do
        it "should return a hash whose values are collections given a hash with values that are not collections" do
          hash = {200 => lambda{|response| }}
          hash = Callback.new(hash).callback_hash
          hash[200].should be_an_instance_of(Array)
        end

        it "should return the hash unchanged if the given hash has values that are collections" do
          hash = {200 => [lambda{|response| }]}
          Callback.new(hash).callback_hash.should == hash
        end
      end

      it "should create a new Callback instance with callback_hash as a key/value pair of HTTP code and collection of lambdas given a block" do
        block = lambda do |callback|
          callback.on_ok{|response| }
        end
        Callback.new(block).callback_hash.should have(1).callbacks_for(200)
      end

      it "should create a new Callback instance with empty callback_hash given an empty block" do
        block = lambda{|callback| }
        Callback.new(block).callback_hash.should be_empty
      end
    end

    context "execute" do
      it "should execute all callbacks registered for HTTP code 200 given a response with the same code" do
        on_ok = false
        on_another_ok = false

        hash = {200 => lambda{|response| on_ok = true}}
        block = lambda do |callback| 
          callback.on_ok{|response| on_another_ok = true}
        end
        uri_callback = Callback.new(hash)
        request_callback = Callback.new(block)
        callback = uri_callback.merge(request_callback)
        callback.execute(response_200)
        on_ok.should be_true
        on_another_ok.should be_true
      end
    end

    context "merge" do
      it "should return a new Callback instance that has callbacks hash from both Callback instances" do
        callback1 = Callback.new({200 => lambda{|response| }})
        block = lambda do |callback|
          callback.on_ok{|response| }
        end
        callback2 = Callback.new(block)
        merged_callback = callback1.merge(callback2)

        merged_callback.callback_hash.should have(2).callbacks_for(200)
      end
    end

    context "on_ok" do
      it "should register a callback on HTTP 200 with the given block" do
        callback = Callback.new({})
        callback.on_ok {|response| }
        callback.callback_hash.should have(1).callbacks_for(200)
      end

      it "should register additional callback if a callback for HTTP 200 already exists with the given block" do
        callback = Callback.new(200 => lambda{|response| })
        callback.on_ok {|response| }
        callback.callback_hash.should have(2).callbacks_for(200)
      end

      it "should not have any effect if called without a block" do
        on_ok = false
        callback = Callback.new({})
        callback.on_ok
        callback.execute(response_200)
        on_ok.should be_false
      end
    end

    context "custom codes" do
      let(:code){200}
      it "should register a callback given a code as integer" do
        callback = Callback.new({})
        callback.on(code) {|response| }
        callback.callback_hash.should have(1).callbacks_for(200)
      end

      it "should register another callback given a code as integer is already registered" do
        callback = Callback.new(code => lambda{|response| })
        callback.on(code) {|response| }
        callback.callback_hash.should have(2).callbacks_for(200)
      end

      it "should register a callback given a code as range" do
        code = 200..206
        callback = Callback.new({})
        callback.on(code) {|response| }
        callback.callback_hash.should have(1).callbacks_for(200..206)
      end

      it "should register another callback given a code as range is already registered" do
        code = 200..206
        callback = Callback.new(code => lambda{|response| })
        callback.on(code) {|response| }
        callback.callback_hash.should have(2).callbacks_for(200..206)
      end

      it "should execute a callback registered for a range of response codes given a response with code that falls in the range" do
        on_ok = false
        code = 200..206
        callback = Callback.new({})
        callback.on(code) {|response| on_ok = true}
        callback.execute(response_200)
        on_ok.should be_true
      end

      it "should not execute a callback registered for a range of response codes given a reponse with code that does not fall in the range" do
        block_executed = false
        code = 200..206
        callback = Callback.new(code => lambda{|response| block_executed = true})
        response_301 = mock(Net::HTTPOK, :code => 301, :message => "moved permanenlty", :body => '', :to_hash => {})
        callback.execute(response_301)
        block_executed.should be_false
      end
    end
  end
end
