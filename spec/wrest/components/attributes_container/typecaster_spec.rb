require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Components
  describe AttributesContainer::Typecaster do
    before :each do
      @Demon = Class.new
      @Demon.class_eval do
        include Wrest::Components::AttributesContainer
        include Wrest::Components::AttributesContainer::Typecaster
      end
    end

    it "should know how to apply a lambda to the string value of a given key casting it to a new type" do
      @Demon.class_eval{ typecast :age => lambda{|id_string| id_string.to_i} }
      kai_wren = @Demon.new('age' => '1')
      kai_wren.age.should == 1
    end

    it "should not apply a lambda to the value of a given key if it is not a string" do
      @Demon.class_eval{ typecast :age => lambda{|id_string| id_string.to_i} }
      kai_wren = @Demon.new('age' => :ooga)
      kai_wren.age.should == :ooga
    end

    it "should leave nils unchanged" do
      @Demon.class_eval{ typecast :age => lambda{|id_string| id_string.to_i} }
      kai_wren = @Demon.new('age' => nil)
      kai_wren.age.should be_nil
    end

    it "should provide helpers for typcasting common types" do
      @Demon.class_eval{ typecast :age => as_integer }
      kai_wren = @Demon.new('age' => '1500')
      kai_wren.age.should == 1500
    end

    describe 'in subclasses' do
      before :each do
        @Sidhe = Class.new
        @Sidhe.class_eval do
          include Wrest::Components::AttributesContainer
          include Wrest::Components::AttributesContainer::Typecaster

          typecast :age => as_integer
        end
      end

      it "should inherit all defined typecasts" do
        @ChineseSidhe = Class.new(@Sidhe)
        kai_wren = @ChineseSidhe.new('age' => '1500')
        kai_wren.age.should == 1500
      end

      it "should discard all typecasts from parent if defined in child" do
        @ChineseSidhe = Class.new(@Sidhe)
        @ChineseSidhe.class_eval{ typecast :born_in => as_integer }
        kai_wren = @ChineseSidhe.new('age' => '1500', 'born_in' => '509')
        kai_wren.age.should == '1500'
        kai_wren.born_in.should == 509
      end
    end
  end
end
