require File.dirname(__FILE__) + '/../../spec_helper'
require "#{Wrest::Root}/wrest/native"
Wrest::Http = Wrest::Native

module Wrest
  describe Native::Session do
    xit "should know how to use the connection provided to make requests" do
      Native::Session.new('http://github.com') do |session|
        session.get('/repositories').should_not be_connection_closed
      end
    end

    it "should have a empty string for a body" do
      'http://localhost:3000/no_body'.to_uri.get.body.should == " "
      'http://localhost:3000/nothing'.to_uri.get.body.should == " "
      'http://localhost:3000/nothing'.to_uri.post.body.should == " "
      'http://localhost:3000/no_bodies.xml'.to_uri.post.body.should == " "
    end
  end
end
