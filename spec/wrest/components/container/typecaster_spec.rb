# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable RSpec/DescribedClass
RSpec.describe Wrest::Components::Container::Typecaster do
  let(:demon_klass) { Class.new }

  before do
    demon_klass.class_eval do
      include Wrest::Components::Container
      include Wrest::Components::Container::Typecaster # rubocop:disable RSpec/DescribedClass
    end
  end

  it 'knows how to apply a lambda to the string value of a given key casting it to a new type' do
    demon_klass.class_eval { typecast age: ->(id_string) { id_string.to_i } }
    kai_wren = demon_klass.new('age' => '1')
    expect(kai_wren.age).to eq(1)
  end

  describe 'where the value is not a typecastable type' do
    it 'string should not typecast' do
      demon_klass.class_eval { typecast age: ->(id_string) { id_string.to_i } }
      kai_wren = demon_klass.new('age' => :ooga)
      expect(kai_wren.age).to eq(:ooga)
    end

    it 'hash should not typecast' do
      test_user_klass = Class.new
      test_user_klass.send(:include, Wrest::Components::Container)

      demon_klass.class_eval { typecast user: ->(user) { test_user_klass.new(user) } }

      kai_wren = demon_klass.new('user' => { 'foo' => 'bar' })
      expect(kai_wren.user.class).to eq(test_user_klass)
      expect(kai_wren.user.foo).to eq('bar')
    end

    it 'array should not typecast' do
      demon_klass.class_eval { typecast addresses: ->(addresses) { addresses.first } }
      kai_wren = demon_klass.new('addresses' => %w[foo bar])
      expect(kai_wren.addresses).to eq('foo')
    end
  end

  it 'leaves nils unchanged' do
    demon_klass.class_eval { typecast age: ->(id_string) { id_string.to_i } }
    kai_wren = demon_klass.new('age' => nil)
    expect(kai_wren.age).to be_nil
  end

  it 'provides helpers for typcasting common types' do
    demon_klass.class_eval { typecast age: as_integer }
    kai_wren = demon_klass.new('age' => '1500')
    expect(kai_wren.age).to eq(1500)
  end

  describe 'in subclasses' do
    let(:sidhe_klass) { Class.new }

    before do
      sidhe_klass.class_eval do
        include Wrest::Components::Container
        include Wrest::Components::Container::Typecaster # rubocop:disable RSpec/DescribedClass

        typecast age: as_integer
      end
    end

    it 'inherits all defined typecasts' do
      chinese_sidhe_klass = Class.new(sidhe_klass)
      kai_wren = chinese_sidhe_klass.new('age' => '1500')
      expect(kai_wren.age).to eq(1500)
    end

    it 'discards all typecasts from parent if defined in child' do
      chinese_sidhe_klass = Class.new(sidhe_klass)
      chinese_sidhe_klass.class_eval { typecast born_in: as_integer }
      kai_wren = chinese_sidhe_klass.new('age' => '1500', 'born_in' => '509')
      expect(kai_wren.age).to eq('1500')
      expect(kai_wren.born_in).to eq(509)
    end
  end
end
# rubocop:enable RSpec/DescribedClass
