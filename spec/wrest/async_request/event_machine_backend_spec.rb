require "spec_helper"

Wrest::AsyncRequest.enable_em

module Wrest::AsyncRequest
  describe EventMachineBackend do

    describe "executing requests" do
      it "should execute the given request asynchronously using eventmachine" do
        hash = {}
        uri = "http://localhost:3000".to_uri
        request = Wrest::Native::Get.new(uri,{},{},:callback => Wrest::Callback.new({200 => lambda{|response| hash["success"] = true}}))
        response_200 = mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {})
        request.should_receive(:do_request).and_return(response_200)

        async_obj = EventMachineBackend.new
        async_obj.execute(request)
        sleep 1
        hash.key?("success").should be_true
      end
    end
  end
end
