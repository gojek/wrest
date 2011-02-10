require "spec_helper"

module Wrest
  describe AsyncRequest do
    context "default_to_em!" do
      it "should change the default backend for asynchronous requests to eventmachine" do
        AsyncRequest.default_to_em!
        AsyncRequest.default_backend.should be_an_instance_of(AsyncRequest::EventMachineBackend)
      end
    end

    context "default_to_threads!" do
      it "should change the default backend for asynchronous requests to threads" do
        AsyncRequest.default_to_threads!
        AsyncRequest.default_backend.should be_an_instance_of(AsyncRequest::ThreadBackend)
      end
    end

    context "default_backend=" do
      it "should change the default backend to the given backend" do
        AsyncRequest.enable_em
        AsyncRequest.default_backend = AsyncRequest::EventMachineBackend.new
        AsyncRequest.default_backend.should be_an_instance_of(AsyncRequest::EventMachineBackend)
      end
    end
  end
end
