require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest::Components
  describe Translators do
    it "should know how to raise an exception if the mime type doesn't exist" do
      lambda{ Translators.lookup('weird/unknown')}.should raise_error(Wrest::Exceptions::UnsupportedContentTypeException)
    end
  end
end
