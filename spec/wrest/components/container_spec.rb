# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require "spec_helper"

module Wrest::Components
  describe Container do
    class HumanBeing
      include Wrest::Components::Container
      always_has :id
    end

    class WaterMagician < HumanBeing
    end

    it "should allow instantiation with no attributes" do
      expect{ HumanBeing.new }.to_not raise_error
    end

    describe 'serialisation' do
      it "should know its xml element name" do
        expect(HumanBeing.element_name).to eq('human_being')
      end

      it "should know how to serialise itself given any of the Wrest::Components::Translators" do
        result = HumanBeing.new(:age => "70", :name => 'Li Piao').serialise_using(Wrest::Components::Translators::Json)
        expectedPermutationOne = "{\"age\":\"70\",\"name\":\"Li Piao\"}"
        expectedPermutationTwo = "{\"name\":\"Li Piao\",\"age\":\"70\"}"

        expect((result == expectedPermutationOne || result == expectedPermutationTwo)).to be_truthy
      end

      it "should have a to_xml helper that ensures that the name of the class is the root of the serilised form" do
        result = HumanBeing.new(:age => "70", :name => 'Li Piao').to_xml
        expectedPermutationOne = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<human-being>\n  <age>70</age>\n  <name>Li Piao</name>\n</human-being>\n"
        expectedPermutationTwo = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<human-being>\n  <name>Li Piao</name>\n  <age>70</age>\n</human-being>\n"

        expect((result == expectedPermutationOne || result == expectedPermutationTwo)).to be_truthy
      end

      describe 'subclasses' do
        it "should not allow cached element name to clash" do
          expect(WaterMagician.element_name).to eq('water_magician')
          expect(HumanBeing.element_name).to eq('human_being')
        end
      end
    end

    describe "typecasting" do
      before(:each) do
        @Demon = Class.new

        @Demon.class_eval do
          include Wrest::Components::Container
        end
      end

      it "should delegate to Container::Typecaster#typecast to actually do the typecasting" do
        @Demon.class_eval do
          typecast :foo => lambda{|value| value.to_i}
        end
        expect(@Demon.new(:foo => '1').foo).to eq(1)
      end

      it "should provide helpers for common typecasts" do
        @Demon.class_eval do
          typecast :foo => as_integer
        end
        expect(@Demon.new(:foo => '1').foo).to eq(1)
      end
    end

    describe 'always_has' do
      describe 'method creation' do
        before :each do
          @Demon = Class.new
        end

        # Methods are string in 1.8 and symbols in 1.9. We'll use to_sym to
        # allow us to build on both.
        it "should define attribute getters at the class level" do
          kai_wren = @Demon.new
          expect(kai_wren.methods.map(&:to_sym)).to_not include(:trainer)

          @Demon.class_eval{
            include Wrest::Components::Container
            always_has :trainer
          }

          expect(kai_wren.methods.map(&:to_sym)).to include(:trainer)
        end

        it "should define attribute setters at the class level" do
          kai_wren = @Demon.new
          expect(kai_wren.methods.map(&:to_sym)).to_not include(:trainer=)

          @Demon.class_eval{
            include Wrest::Components::Container
            always_has :trainer
          }

          expect(kai_wren.methods.map(&:to_sym)).to include(:trainer=)
        end

        it "should define attribute query methods at the class level" do
          kai_wren = @Demon.new
          expect(kai_wren.methods.map(&:to_sym)).to_not include(:trainer?)

          @Demon.class_eval{
            include Wrest::Components::Container
            always_has :trainer
          }
          expect(kai_wren.methods.map(&:to_sym)).to include(:trainer?)
        end
      end

      describe 'method functionality' do
        before :each do
          @Demon = Class.new
          @Demon.class_eval{
            include Wrest::Components::Container
            always_has :trainer

            def method_missing(method_name, *args)
              # Ensuring that the instance level
              # attribute methods don't kick in
              # by overriding method_missing
              raise NoMethodError.new("Method #{method_name} was invoked, but doesn't exist", method_name)
            end
          }
          @kai_wren = @Demon.new
        end

        it "should define attribute getters at the class level" do
          @kai_wren.instance_variable_get("@attributes")[:trainer] = 'Viss'
          expect(@kai_wren.trainer).to eq('Viss')
        end

        it "should define attribute setters at the class level" do
          @kai_wren.trainer = 'Viss'
          expect(@kai_wren.instance_variable_get("@attributes")[:trainer]).to eq('Viss')
        end

        it "should define attribute query methods at the class level" do
          expect(@kai_wren.trainer?).to be_falsey
          @kai_wren.instance_variable_get("@attributes")[:trainer] = 'Viss'
          expect(@kai_wren.trainer?).to be_truthy
        end
      end
    end

    describe 'provides an attributes interface which' do
      before :each do
        @li_piao = HumanBeing.new(:id => 5, :profession => 'Natural Magician', 'enhanced_by' => 'Kai Wren')
      end

      context 'access key format' do
        it "should provide a generic key based setter that understands symbols" do
          @li_piao[:enhanced_by] = "Viss"
          expect(@li_piao.instance_variable_get('@attributes')['enhanced_by']).to eq("Viss")
        end

        it "should provide a generic key based setter that understands strings" do
          @li_piao['enhanced_by'] = "Viss"
          expect(@li_piao.instance_variable_get('@attributes')['enhanced_by']).to eq("Viss")
        end

        it "should provide a generic key based getter that understands symbols" do
          expect(@li_piao[:profession]).to eq("Natural Magician")
        end

        it "should provide a generic key based getter that understands strings" do
          expect(@li_piao['profession']).to eq("Natural Magician")
        end
      end

      it "should fail when getter methods for attributes that don't exist are invoked" do
        expect{ @li_piao.ooga }.to raise_error(NoMethodError)
      end

      it "should provide getter methods for attributes" do
        expect(@li_piao.profession).to eq('Natural Magician')
        expect(@li_piao.enhanced_by).to eq('Kai Wren')
      end

      it "should respond to getter methods for attributes" do
        expect(@li_piao).to respond_to(:profession)
        expect(@li_piao).to respond_to(:enhanced_by)
      end

      it "should not respond to getter methods for attributes that don't exist" do
        expect(@li_piao).to_not respond_to(:gods)
      end

      it "should create a setter method when one is invoked for attributes that don't exist" do
        @li_piao.niece = 'Li Plum'
        expect(@li_piao.instance_variable_get('@attributes')[:niece]).to eq('Li Plum')
        expect(@li_piao.niece).to eq('Li Plum')
      end

      it "should provide setter methods for attributes" do
        @li_piao.enhanced_by = 'He of the Towers of Light'
        expect(@li_piao.instance_variable_get('@attributes')[:enhanced_by]).to eq('He of the Towers of Light')
      end

      it "should respond to setter methods for attributes" do
        expect(@li_piao).to respond_to(:profession=)
        expect(@li_piao).to respond_to(:enhanced_by=)
      end

      it "should not respond to setter methods for attributes that don't exist" do
        expect(@li_piao).to_not respond_to(:god=)
      end

      it "should return false when query methods for attributes that don't exist are invoked" do
        expect(@li_piao.ooga?).to be_falsey
      end

      it "should provide query methods for attributes" do
        li_piao = HumanBeing.new( :profession => 'Natural Magician', :enhanced_by => nil)
        expect(li_piao.profession?).to be_truthy
        expect(li_piao.enhanced_by?).to be_falsey
        expect(li_piao.gender?).to be_falsey
      end

      it "should respond to query methods for attributes" do
        expect(@li_piao).to respond_to(:profession?)
        expect(@li_piao).to respond_to(:enhanced_by?)
      end

      it "should not respond to query methods for attributes that don't exist" do
        expect(@li_piao).to_not respond_to(:theronic?)
      end

      it "should override methods which already exist on the container" do
        expect(@li_piao.id).to eq(5)
        @li_piao.id = 6
        expect(@li_piao.id).to eq(6)
      end

      it "should provide getter and query methods to instance which has corresponding attribute" do
        zotoh_zhaan = HumanBeing.new(:species => "Delvian")
        expect(zotoh_zhaan.species).to eq("Delvian")
        expect(zotoh_zhaan.species?).to be_truthy
        zotoh_zhaan.species = "Human"
        expect{ @li_piao.species }.to raise_error(NoMethodError)
        expect(@li_piao.species?).to be_falsey
        expect(@li_piao).to_not respond_to(:species=)
        expect(@li_piao.methods.grep(/:species=/)).to be_empty
      end
    end
  end
end
