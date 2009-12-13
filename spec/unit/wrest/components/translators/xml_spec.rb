require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Components::Translators
  describe Xml do
    it "should know how to convert xml to a hashmap" do
      http_response = mock('Http Reponse')
      http_response.should_receive(:body).and_return("<ooga><age>12</age></ooga>")

      Xml.deserialise(http_response).should == {"ooga"=>{"age"=> "12"}}
    end

    it "should know how to convert a hashmap to xml" do
      Xml.serialise({"ooga"=>{"age" => "12"}}).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <ooga>\n    <age>12</age>\n  </ooga>\n</hash>\n"
    end
  end
end
