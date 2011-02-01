require "spec_helper"
require "#{Wrest::Root}/wrest"

module Wrest
  describe CallbackBuilder do
    context "registering callback with on_ok" do
      it "should register a callback for 200 with the given block" do
        callback_builder = CallbackBuilder.new
        callback_builder.on_ok {|response| }
        callback_builder.build.should have(1).callbacks_for(200)
      end

      it "should register another callback on 200 if a callback on 200 is already registered" do
        callback_builder = CallbackBuilder.new(200 => lambda{|response| })
        callback_builder.on_ok {|response| }
        callback_builder.build.should have(2).callbacks_for(200)
      end

      it "should have no effect if called without a block" do
        callback_builder = CallbackBuilder.new()
        callback_builder.on_ok 
        callback_builder.build.should_not have_key(200)
      end
    end

    context "calling build after" do
      context "creating a new CallbackBuilder instance given a hash with 200 as key and a block as value" do
        it "should return a hash with 200 as key and list of size 1 with the given block with arity 1 as value" do
          block = Proc.new {|response| }
          hash = {200 => block}
          callbacks = CallbackBuilder.new(hash).build
          callbacks.should have(1).callbacks_for(200)
        end
      end

      context "calling update with a block containing a call to on_ok" do
        it "should return a hash with 200 as key and list of size 1 with the given block with arity 1 as value" do
          block = Proc.new {|callback_builder|
            callback_builder.on_ok {|response| }
          }
          callback_builder = CallbackBuilder.new
          callback_builder.update(block)
          callbacks = callback_builder.build

          callbacks.should have(1).callbacks_for(200)
        end
      end

      context "creating a new CallbackBuilder instance with a hash with 200/block as key/value and calling update with a block containing a call to on_ok" do
        it "should return a hash with 200 as key and list of size 2 with the given blocks with arity 1 as value" do
          block = Proc.new {|callback_builder|
            callback_builder.on_ok {|response| }
          }

          hash = {200 => Proc.new {|response| }}
          callback_builder = CallbackBuilder.new(hash)
          callback_builder.update(block)
          callbacks = callback_builder.build

          callbacks.should have(2).callbacks_for(200)
        end
      end
    end

    context "custom codes" do
      let(:code){200}
      it "should register a callback given a code as integer" do
        callback_builder = CallbackBuilder.new
        callback_builder.on(code) {|response| }
        callbacks = callback_builder.build

        callbacks.should have(1).callbacks_for(code)
      end

      it "should register another callback given a code as integer is already registered" do
        callback_builder = CallbackBuilder.new(200 => lambda{|response| })
        callback_builder.on(code) {|response| }
        callbacks = callback_builder.build

        callbacks.should have(2).callbacks_for(code)
      end

      it "should register a callback given a code as range" do
        code = 200..206
        callback_builder = CallbackBuilder.new
        callback_builder.on(code) {|response| }
        callbacks = callback_builder.build

        callbacks.should have(1).callbacks_for(code)
      end

      it "should register a callback given a code as range is already registered" do
        code = 200..206
        callback_builder = CallbackBuilder.new(200..206 => lambda{|response| })
        callback_builder.on(code) {|response| }
        callbacks = callback_builder.build

        callbacks.should have(2).callbacks_for(code)
      end
    end

    context "execution of registered callbacks" do
      let(:response_200){mock(Net::HTTPOK, :code => 200, :message => "OK", :body => '', :to_hash => {})}
      it "should execute a callback registered for a response code given a response with the same code" do
        block_executed = false
        callback_builder = CallbackBuilder.new(200 => lambda{|response| block_executed = true})
        callback_builder.execute_callbacks(response_200)
        block_executed.should be_true
      end

      it "should not execute a callback registered for a response code given a response with a different code" do
        block_executed = false
        callback_builder = CallbackBuilder.new(201 => lambda{|response| block_executed = true})
        callback_builder.execute_callbacks(response_200)
        block_executed.should be_false
      end

      it "should execute all callbacks registered for a response code given a response with the same code" do
        block_executed = false
        another_block_executed = false
        callback_builder = CallbackBuilder.new(200 => [lambda{|response| block_executed = true}, lambda{|response| another_block_executed = true}])
        callback_builder.execute_callbacks(response_200)
        block_executed.should be_true
        another_block_executed.should be_true
      end

      it "should execute a callback registered for a range of response codes given a reponse with code that falls in the range" do
        block_executed = false
        callback_builder = CallbackBuilder.new(200..206 => lambda{|response| block_executed = true})
        response_202 = mock(Net::HTTPOK, :code => 202, :message => "accepted", :body => '', :to_hash => {})
        callback_builder.execute_callbacks(response_202)
        block_executed.should be_true
      end

      it "should not execute a callback registered for a range of response codes given a reponse with code that does not fall in the range" do
        block_executed = false
        callback_builder = CallbackBuilder.new(200..206 => lambda{|response| block_executed = true})
        response_301 = mock(Net::HTTPOK, :code => 301, :message => "moved permanenlty", :body => '', :to_hash => {})
        callback_builder.execute_callbacks(response_301)
        block_executed.should be_false
      end
    end
  end
end

