require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Mappers
  describe Resource::Base do
    describe 'as a class' do
      before(:each) do
        @Bottle = Class.new(Resource::Base)
      end

      it "should have a method to set the host url" do
        @Bottle.should respond_to(:host=)
      end

      it "should have a method to retrive the host url after it is set" do
        @Bottle.class_eval{ self.host=("http://localhost:3000") }
        @Bottle.should respond_to(:host)
      end

      it "should know what its site is" do
        @Bottle.class_eval{ self.host=("http://localhost:3000") }
        @Bottle.host.should == "http://localhost:3000"
      end

      it "should not use the same string" do
        url = "http://localhost:3000"
        @Bottle.class_eval{ self.host=  url }
        url.upcase!
        @Bottle.host.should == "http://localhost:3000"
      end
    end
  end
end
