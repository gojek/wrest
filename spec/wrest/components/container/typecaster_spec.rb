require 'spec_helper'

module Wrest::Components
  describe Container::Typecaster do
    before do
      @Demon = Class.new
      @Demon.class_eval do
        include Wrest::Components::Container
        include Wrest::Components::Container::Typecaster
      end
    end

    it 'knows how to apply a lambda to the string value of a given key casting it to a new type' do
      @Demon.class_eval { typecast age: ->(id_string) { id_string.to_i } }
      kai_wren = @Demon.new('age' => '1')
      expect(kai_wren.age).to eq(1)
    end

    describe 'where the value is not a typecastable type' do
      it 'string should not typecast' do
        @Demon.class_eval { typecast age: ->(id_string) { id_string.to_i } }
        kai_wren = @Demon.new('age' => :ooga)
        expect(kai_wren.age).to eq(:ooga)
      end

      it 'hash should not typecast' do
        class TestUser
          include Wrest::Components::Container
        end

        @Demon.class_eval { typecast user: ->(user) { TestUser.new(user) } }

        kai_wren = @Demon.new('user' => { 'foo' => 'bar' })
        expect(kai_wren.user.class).to eq(TestUser)
        expect(kai_wren.user.foo).to eq('bar')
      end

      it 'array should not typecast' do
        @Demon.class_eval { typecast addresses: ->(addresses) { addresses.first } }
        kai_wren = @Demon.new('addresses' => %w[foo bar])
        expect(kai_wren.addresses).to eq('foo')
      end
    end

    it 'leaves nils unchanged' do
      @Demon.class_eval { typecast age: ->(id_string) { id_string.to_i } }
      kai_wren = @Demon.new('age' => nil)
      expect(kai_wren.age).to be_nil
    end

    it 'provides helpers for typcasting common types' do
      @Demon.class_eval { typecast age: as_integer }
      kai_wren = @Demon.new('age' => '1500')
      expect(kai_wren.age).to eq(1500)
    end

    describe 'in subclasses' do
      before do
        @Sidhe = Class.new
        @Sidhe.class_eval do
          include Wrest::Components::Container
          include Wrest::Components::Container::Typecaster

          typecast age: as_integer
        end
      end

      it 'inherits all defined typecasts' do
        @ChineseSidhe = Class.new(@Sidhe)
        kai_wren = @ChineseSidhe.new('age' => '1500')
        expect(kai_wren.age).to eq(1500)
      end

      it 'discards all typecasts from parent if defined in child' do
        @ChineseSidhe = Class.new(@Sidhe)
        @ChineseSidhe.class_eval { typecast born_in: as_integer }
        kai_wren = @ChineseSidhe.new('age' => '1500', 'born_in' => '509')
        expect(kai_wren.age).to eq('1500')
        expect(kai_wren.born_in).to eq(509)
      end
    end
  end
end
