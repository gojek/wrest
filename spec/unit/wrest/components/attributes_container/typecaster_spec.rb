require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Components
  describe Container::Typecaster do
    before :each do
      @Demon = Class.new
      @Demon.class_eval do
        include Wrest::Components::Container
        include Wrest::Components::Container::Typecaster
      end
    end

    it "should know how to apply a lambda to the string value of a given key casting it to a new type" do
      @Demon.class_eval{ typecast :age => lambda{|id_string| id_string.to_i} }
      kai_wren = @Demon.new('age' => '1')
      kai_wren.age.should == 1
    end

    describe "where the value is not a typecastable type" do
      it "string should not typecast" do
        @Demon.class_eval{ typecast :age => lambda{|id_string| id_string.to_i} }
        kai_wren = @Demon.new('age' => :ooga)
        kai_wren.age.should == :ooga
      end

      it "hash should not typecast" do
        class TestUser
          include Wrest::Components::Container
        end

        @Demon.class_eval{ typecast :user => lambda{|user| TestUser.new(user)}}

        kai_wren = @Demon.new('user' => {'foo' => 'bar'})
        kai_wren.user.class.should == TestUser
        kai_wren.user.foo.should == 'bar'
      end

      it "array should not typecast" do
        @Demon.class_eval{ typecast :addresses => lambda{|addresses| addresses.first} }
        kai_wren = @Demon.new('addresses' => ['foo', 'bar'])
        kai_wren.addresses.should == 'foo'
      end
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
          include Wrest::Components::Container
          include Wrest::Components::Container::Typecaster

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
