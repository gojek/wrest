require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Http::Session do
    it "should know how to use the connection provided to make requests" do
      uri = "http://localhost:3000".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)
      http.should_receive(:read_timeout=).with(60)

      request_one = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {"Connection"=>"Keep-Alive"})
      request_two = Net::HTTP::Get.new('/bottles.xml', {"Connection"=>"Keep-Alive"})

      Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {"Connection"=>"Keep-Alive"}).and_return(request_one)
      Net::HTTP::Get.should_receive(:new).with('/bottles.xml', {"Connection"=>"Keep-Alive"}).and_return(request_two)

      ok_response = build_ok_response
      ok_response.should_receive(:[]).with(Http::StandardHeaders::Connection).twice.and_return(Http::StandardTokens::KeepAlive)
      
      http.should_receive(:request).with(request_one, nil).and_return(ok_response)
      http.should_receive(:request).with(request_two, nil).and_return(ok_response)

      Http::Session.new(uri) do |session|
        session.get('/glassware', :owner => 'Kai', :type => 'bottle')
        session.get '/bottles.xml'
      end
    end
  end
end
