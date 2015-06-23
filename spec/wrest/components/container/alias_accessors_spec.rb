require "spec_helper"

module Wrest::Components
  describe Container::AliasAccessors do
    before :each do
      @Demon = Class.new
      @Demon.class_eval do
        include Wrest::Components::Container
      end
    end

    it "should provide a macro to enable aliasing accessors" do
      expect{ @Demon.class_eval{ alias_accessors :shiriki => :chambala } }.to_not raise_error(NoMethodError)
    end

    describe 'aliasing' do
      before :each do
        @Demon.class_eval{ alias_accessors :sex => :gender, :age => :maturity }
      end

      it "should provide an accessor methods when we alias to an attribute" do
        demon = @Demon.new
        expect(demon).to respond_to(:gender)
        expect(demon).to respond_to(:gender=)
        expect(demon).to respond_to(:gender?)
        expect(demon).to respond_to(:maturity)
        expect(demon).to respond_to(:maturity=)
        expect(demon).to respond_to(:maturity?)
      end

      it "should ensure that the aliased getter method delegates to the actual getter" do
        demon = @Demon.new :sex => 'male'
        expect(demon.gender).to eq('male')
      end

      it "should ensure that the aliased setter method delegates to the actual getter" do
        demon = @Demon.new
        expect(demon).to receive(:sex=).with('male')
        demon.gender = 'male'
      end

      it "should ensure that the aliased query method delegates to the actual queryier" do
        demon = @Demon.new :age => '1000'
        expect(demon.gender?).to be_falsey
        demon.maturity?.should be_truthy
      end
    end
  end
end
