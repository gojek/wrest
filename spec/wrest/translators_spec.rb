require File.dirname(__FILE__) + '/../spec_helper'

module Wrest
  describe Translators do
    it "should know how to raise an exception if the mime type doesn't exist" do
      lambda{ Components::Translators.lookup('weird/unknown')}.should raise_error(Wrest::UnsupportedContentTypeException)
    end
  end
end
