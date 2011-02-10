require "spec_helper"

module Wrest::AsyncRequest
  describe ThreadBackend do

    describe "executing requests" do
      it "should execute the given request asynchronously using threads" do
        hash = {}
        uri = "http://localhost:3000".to_uri
        request = Wrest::Native::Get.new(uri,{},{},:callback => Wrest::Callback.new({200 => lambda{|response| hash["success"] = true}}))
        response_200 = mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {})
        request.should_receive(:do_request).and_return(response_200)

        async_obj = ThreadBackend.new
        async_obj.execute(request)
        sleep 1
        hash.key?("success").should be_true
      end
    end
  end
end
