require File.dirname(__FILE__) + '/../../spec_helper'

unless RUBY_PLATFORM =~ /java/
  module Wrest
    describe Curl::Request do
      before :all do
        Wrest.use_curl
      end

      it "should raise an exception if an options is invoked" do
        lambda{ 'http://localhost:3000/bottles'.to_uri.options }.should raise_error(Wrest::Exceptions::UnsupportedHttpVerb)
      end

      after :all do
        Wrest.use_native
      end
    end
  end
end
