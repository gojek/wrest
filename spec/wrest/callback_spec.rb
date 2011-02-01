require "spec_helper"
require "#{Wrest::Root}/wrest"

module Wrest
  describe Callback do
    let(:response_200){mock(Net::HTTPOK, :code => 200, :message => "OK", :body => '', :to_hash => {})}
    context "execute" do
      it "should execute all callbacks registered for HTTP code 200 given a response with the same code" do
        on_ok = false
        on_another_ok = false

        hash = {200 => lambda{|response| on_ok = true}}
        block = lambda{|callback| 
          callback.on_ok do |response| 
            on_another_ok = true
          end
        }
        Callback.new(hash).merge(block).execute(response_200)
        on_ok.should be_true
        on_another_ok.should be_true
      end
    end

    context "merge" do
      it "should return a new Callback instance" do
        on_ok = false
        on_another_ok = false

        hash = {200 => lambda{|response| on_ok = true}}
        block = lambda{|callback|
          callback.on_ok do |response|
            on_another_ok = true
          end
        }
        callback = Callback.new(hash)
        merged_callback = callback.merge(block)
        merged_callback.should_not equal(callback)
      end
    end

    context "on_ok" do
      it "should register a callback on HTTP 200 with the given block" do
        on_ok = false
        callback = Callback.new
        callback.on_ok {|response| on_ok = true}
        callback.execute(response_200)
        on_ok.should be_true
      end

      it "should register additional callback if a callback for HTTP 200 already exists with the given block" do
        on_ok = false
        on_another_ok = false
        callback = Callback.new(200 => lambda{|response| on_another_ok = true})
        callback.on_ok {|response| on_ok = true}
        callback.execute(response_200)
        on_ok.should be_true
        on_another_ok.should be_true
      end

      it "should not have any effect if called without a block" do
        on_ok = false
        callback = Callback.new
        callback.on_ok
        callback.execute(response_200)
        on_ok.should be_false
      end
    end
  end
end
