require File.dirname(__FILE__) + '/../spec_helper'

module Wrest
  describe Translators do
    it "should know how to raise an exception if the mime type doesn't exist" do
      lambda{ Translators.load('weird/unknown')}.should raise_error(UnsupportedContentTypeException)
    end
  end
end
