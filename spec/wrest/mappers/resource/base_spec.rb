require File.dirname(__FILE__) + '/../../../spec_helper'

class BottledUniverse < Wrest::Mappers::Resource::Base
  self.host= "http://localhost:3000"
end

class DemonHome < BottledUniverse
  self.host= "http://localhost:3001"
end

module Wrest::Mappers
  describe Resource::Base do
    it "should not affect other classes when setting up its macros" do
      Class.should_not respond_to(:host=)
      Object.should_not respond_to(:host=)
    end

    it "should not affect itself when subclasses use its macros" do
      Resource::Base.should_not respond_to(:host)
    end


    describe 'subclasses' do
      before(:each) do
        @Bottle = Class.new(Resource::Base)
      end
      
      it "should know how to create an instance using deserilised attributes"
      
      it "should have a method to set the host url" do
        @Bottle.should respond_to(:host=)
      end

      it "should have a method to retrive the host url after it is set" do
        @Bottle.class_eval{ self.host= "http://localhost:3000" }
        @Bottle.should respond_to(:host)
      end

      it "should know what its site is" do
        @Bottle.class_eval{ self.host= "http://localhost:3000" }
        @Bottle.host.should == "http://localhost:3000"
      end

      it "should not use the same string" do
        url = "http://localhost:3000"
        @Bottle.class_eval{ self.host=  url }
        url.upcase!
        @Bottle.host.should == "http://localhost:3000"
      end

      it "should know its resource path" do
        BottledUniverse.resource_path.should == '/bottled_universes'
      end
    end

    describe 'subclasses of sublasses' do
      it "should configure its host without affecting its superclass" do
        BottledUniverse.host.should == "http://localhost:3000"
        DemonHome.host.should == "http://localhost:3001"
      end

      it "should know its resource path when it is a subclass of a subclass" do
        DemonHome.resource_path.should == '/demon_homes'
      end
    end
  end
end
