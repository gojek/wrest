require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Http::Response do
    it "should know how to delegate to a translator" do
      http_response = mock('response')
      Components::Translators::Xml.should_receive(:deserialise).with(http_response)
      Http::Response.new(http_response).deserialise_using(Components::Translators::Xml)
    end

    it "should know how to load a translator based on content type" do
      http_response = mock('response')
      http_response.should_receive(:content_type).and_return('application/xml')

      response = Http::Response.new(http_response)
      response.should_receive(:deserialise_using).with(Components::Translators::Xml)

      response.deserialise
    end
  end
end
