require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Components
  describe Container::AliasAccessors do
    before :each do
      @Demon = Class.new
      @Demon.class_eval do
        include Wrest::Components::Container
      end
    end

    it "should provide a macro to enable aliasing accessors" do
      lambda{ @Demon.class_eval{ alias_accessors :shiriki => :chambala } }.should_not raise_error(NoMethodError)
    end

    describe 'aliasing' do
      before :each do
        @Demon.class_eval{ alias_accessors :sex => :gender, :age => :maturity }
      end

      it "should provide an accessor methods when we alias to an attribute" do
        demon = @Demon.new
        demon.should respond_to(:gender)
        demon.should respond_to(:gender=)
        demon.should respond_to(:gender?)
        demon.should respond_to(:maturity)
        demon.should respond_to(:maturity=)
        demon.should respond_to(:maturity?)
      end

      it "should ensure that the aliased getter method delegates to the actual getter" do
        demon = @Demon.new :sex => 'male'
        demon.gender.should == 'male'
      end

      it "should ensure that the aliased setter method delegates to the actual getter" do
        demon = @Demon.new
        demon.should_receive(:sex=).with('male')
        demon.gender = 'male'
      end

      it "should ensure that the aliased query method delegates to the actual queryier" do
        demon = @Demon.new :age => '1000'
        demon.gender?.should be_false
        demon.maturity?.should be_true
      end
    end
  end
end
