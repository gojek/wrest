require File.dirname(__FILE__) + '/../../spec_helper'
require "#{WREST_ROOT}/wrest/curl"

module Wrest
  describe Curl::Request do
    it "should have a empty string for a body" do
      p Wrest::Curl::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri).invoke.body
    end
  end
end
