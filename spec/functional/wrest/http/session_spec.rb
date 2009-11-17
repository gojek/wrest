require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Http::Session do
    it "should know how to use the connection provided to make requests" do
      Http::Session.new('http://github.com'.to_uri) do |session|
        session.get('/repositories').should_not be_connection_closed
      end
    end
  end
end
