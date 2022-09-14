# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

# rubocop:disable RSpec/DescribedClass
RSpec.describe Wrest::Components::Container do
  let(:human_being_klass) do
    Class.new.tap do |klass|
      klass.class_eval do
        include Wrest::Components::Container
        always_has :id
      end
    end
  end

  let(:water_magician_klass) do
    Class.new(human_being_klass)
  end

  before do
    Object.const_set(:HumanBeing, human_being_klass)
    Object.const_set(:WaterMagician, water_magician_klass)
  end

  after do
    Object.send(:remove_const, :HumanBeing)
    Object.send(:remove_const, :WaterMagician)
  end

  it 'allows instantiation with no attributes' do
    expect { HumanBeing.new }.not_to raise_error
  end

  describe 'serialisation' do
    it 'knows its xml element name' do
      expect(HumanBeing.element_name).to eq('human_being')
    end

    it 'knows how to serialise itself given any of the Wrest::Components::Translators' do
      result = HumanBeing.new(age: '70', name: 'Li Piao').serialise_using(Wrest::Components::Translators::Json)
      expected_json = '{"human_being":{"age":"70","name":"Li Piao"}}'

      expect(result).to eq(expected_json)
    end

    it 'has a to_xml helper that ensures that the name of the class is the root of the serialised form' do
      result = HumanBeing.new(age: '70', name: 'Li Piao').to_xml
      expected_xml = "<?xml version=\"1.0\"?>\n<human_being>\n  <age>70</age>\n  <name>Li Piao</name>\n</human_being>\n"

      expect(result).to eq(expected_xml)
    end

    describe 'subclasses' do
      it 'does not allow cached element name to clash' do
        expect(WaterMagician.element_name).to eq('water_magician')
        expect(HumanBeing.element_name).to eq('human_being')
      end
    end
  end

  describe 'typecasting' do
    let(:demon_klass) { Class.new }

    before do
      demon_klass.class_eval do
        include Wrest::Components::Container
      end
    end

    it 'delegates to Container::Typecaster#typecast to actually do the typecasting' do
      demon_klass.class_eval do
        typecast foo: ->(value) { value.to_i }
      end
      expect(demon_klass.new(foo: '1').foo).to eq(1)
    end

    it 'provides helpers for common typecasts' do
      demon_klass.class_eval do
        typecast foo: as_integer
      end
      expect(demon_klass.new(foo: '1').foo).to eq(1)
    end
  end

  describe 'always_has' do
    describe 'method creation' do
      let(:demon_klass) { Class.new }

      # Methods are string in 1.8 and symbols in 1.9. We'll use to_sym to
      # allow us to build on both.
      it 'defines attribute getters at the class level' do
        kai_wren = demon_klass.new
        expect(kai_wren.methods.map(&:to_sym)).not_to include(:trainer)

        demon_klass.class_eval do
          include Wrest::Components::Container
          always_has :trainer
        end

        expect(kai_wren.methods.map(&:to_sym)).to include(:trainer)
      end

      it 'defines attribute setters at the class level' do
        kai_wren = demon_klass.new
        expect(kai_wren.methods.map(&:to_sym)).not_to include(:trainer=)

        demon_klass.class_eval do
          include Wrest::Components::Container
          always_has :trainer
        end

        expect(kai_wren.methods.map(&:to_sym)).to include(:trainer=)
      end

      it 'defines attribute query methods at the class level' do
        kai_wren = demon_klass.new
        expect(kai_wren.methods.map(&:to_sym)).not_to include(:trainer?)

        demon_klass.class_eval do
          include Wrest::Components::Container
          always_has :trainer
        end
        expect(kai_wren.methods.map(&:to_sym)).to include(:trainer?)
      end
    end

    describe 'method functionality' do
      let(:demon_klass) { Class.new }
      let(:kai_wren) { demon_klass.new }

      before do
        demon_klass.class_eval do
          include Wrest::Components::Container
          always_has :trainer

          def method_missing(method_name, *_args)
            # Ensuring that the instance level
            # attribute methods don't kick in
            # by overriding method_missing
            raise NoMethodError.new("Method #{method_name} was invoked, but doesn't exist", method_name)
          end

          def respond_to_missing?(_method_name, *)
            false
          end
        end
      end

      it 'defines attribute getters at the class level' do
        kai_wren.instance_variable_get('@attributes')[:trainer] = 'Viss'
        expect(kai_wren.trainer).to eq('Viss')
      end

      it 'defines attribute setters at the class level' do
        kai_wren.trainer = 'Viss'
        expect(kai_wren.instance_variable_get('@attributes')[:trainer]).to eq('Viss')
      end

      it 'defines attribute query methods at the class level' do
        expect(kai_wren).not_to be_trainer
        kai_wren.instance_variable_get('@attributes')[:trainer] = 'Viss'
        expect(kai_wren).to be_trainer
      end
    end
  end

  describe 'provides an attributes interface which' do
    let(:li_piao) { HumanBeing.new(id: 5, profession: 'Natural Magician', 'enhanced_by' => 'Kai Wren') }

    context 'access key format' do
      it 'provides a generic key based setter that understands symbols' do
        li_piao[:enhanced_by] = 'Viss'
        expect(li_piao.instance_variable_get('@attributes')['enhanced_by']).to eq('Viss')
      end

      it 'provides a generic key based setter that understands strings' do
        li_piao['enhanced_by'] = 'Viss'
        expect(li_piao.instance_variable_get('@attributes')['enhanced_by']).to eq('Viss')
      end

      it 'provides a generic key based getter that understands symbols' do
        expect(li_piao[:profession]).to eq('Natural Magician')
      end

      it 'provides a generic key based getter that understands strings' do
        expect(li_piao['profession']).to eq('Natural Magician')
      end
    end

    it "fails when getter methods for attributes that don't exist are invoked" do
      expect { li_piao.ooga }.to raise_error(NoMethodError)
    end

    it 'provides getter methods for attributes' do
      expect(li_piao.profession).to eq('Natural Magician')
      expect(li_piao.enhanced_by).to eq('Kai Wren')
    end

    it 'responds to getter methods for attributes' do
      expect(li_piao).to respond_to(:profession)
      expect(li_piao).to respond_to(:profession?)
      expect(li_piao).to respond_to(:profession=)
      expect(li_piao).to respond_to(:enhanced_by)
      expect(li_piao).to respond_to(:enhanced_by?)
      expect(li_piao).to respond_to(:enhanced_by=)
    end

    it "does not respond to getter methods for attributes that don't exist" do
      expect(li_piao).not_to respond_to(:gods)
    end

    it "creates a setter method when one is invoked for attributes that don't exist" do
      li_piao.niece = 'Li Plum'
      expect(li_piao.instance_variable_get('@attributes')[:niece]).to eq('Li Plum')
      expect(li_piao.niece).to eq('Li Plum')
    end

    it 'provides setter methods for attributes' do
      li_piao.enhanced_by = 'He of the Towers of Light'
      expect(li_piao.instance_variable_get('@attributes')[:enhanced_by]).to eq('He of the Towers of Light')
    end

    it 'responds to setter methods for attributes' do
      expect(li_piao).to respond_to(:profession=)
      expect(li_piao).to respond_to(:enhanced_by=)
    end

    it "does not respond to setter methods for attributes that don't exist" do
      expect(li_piao).not_to respond_to(:god=)
    end

    it "returns false when query methods for attributes that don't exist are invoked" do
      expect(li_piao.ooga?).to be_falsey
    end

    it 'provides query methods for attributes' do
      li_piao = HumanBeing.new(profession: 'Natural Magician', enhanced_by: nil)
      expect(li_piao.profession?).to be_truthy
      expect(li_piao.enhanced_by?).to be_falsey
      expect(li_piao.gender?).to be_falsey
    end

    it 'responds to query methods for attributes' do
      expect(li_piao).to respond_to(:profession?)
      expect(li_piao).to respond_to(:enhanced_by?)
    end

    it "does not respond to query methods for attributes that don't exist" do
      expect(li_piao).not_to respond_to(:theronic?)
    end

    it 'overrides methods which already exist on the container' do
      expect(li_piao.id).to eq(5)
      li_piao.id = 6
      expect(li_piao.id).to eq(6)
    end

    it 'provides getter and query methods to instance which has corresponding attribute' do
      zotoh_zhaan = HumanBeing.new(species: 'Delvian')
      expect(zotoh_zhaan.species).to eq('Delvian')
      expect(zotoh_zhaan.species?).to be_truthy
      zotoh_zhaan.species = 'Human'
      expect { li_piao.species }.to raise_error(NoMethodError)
      expect(li_piao.species?).to be_falsey
      expect(li_piao).not_to respond_to(:species=)
      expect(li_piao.methods.grep(/:species=/)).to be_empty
    end
  end
end
# rubocop:enable RSpec/DescribedClass
