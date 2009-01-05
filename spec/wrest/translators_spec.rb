require File.dirname(__FILE__) + '/../spec_helper'

module Wrest
  describe Translators do
    it "should know how to raise an exception if the mime type doesn't exist" do
      response = mock 'Http::Response'
      response.should_receive(:content_type).and_return('weird/unknown')
      lambda{ Translators.build(response)}.should raise_error(UnsupportedMimeTypeException)
    end
  end
end
