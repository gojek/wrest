# frozen_string_literal: true

require 'spec_helper'

module Wrest::Components
  describe Container::AliasAccessors do
    before do
      @Demon = Class.new
      @Demon.class_eval do
        include Wrest::Components::Container
      end
    end

    it 'provides a macro to enable aliasing accessors' do
      expect { @Demon.class_eval { alias_accessors shiriki: :chambala } }.not_to raise_error(NoMethodError)
    end

    describe 'aliasing' do
      before do
        @Demon.class_eval { alias_accessors sex: :gender, age: :maturity }
      end

      it 'provides an accessor methods when we alias to an attribute' do
        demon = @Demon.new
        expect(demon).to respond_to(:gender)
        expect(demon).to respond_to(:gender=)
        expect(demon).to respond_to(:gender?)
        expect(demon).to respond_to(:maturity)
        expect(demon).to respond_to(:maturity=)
        expect(demon).to respond_to(:maturity?)
      end

      it 'ensures that the aliased getter method delegates to the actual getter' do
        demon = @Demon.new sex: 'male'
        expect(demon.gender).to eq('male')
      end

      it 'ensures that the aliased setter method delegates to the actual getter' do
        demon = @Demon.new
        expect(demon).to receive(:sex=).with('male')
        demon.gender = 'male'
      end

      it 'ensures that the aliased query method delegates to the actual queryier' do
        demon = @Demon.new age: '1000'
        expect(demon.gender?).to be_falsey
        demon.maturity?.should be_truthy
      end
    end
  end
end
