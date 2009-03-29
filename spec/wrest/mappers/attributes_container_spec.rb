# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest::Mappers
  describe AttributesContainer do
    class HumanBeing
      include AttributesContainer
    end
    
    it "should allow instantiation with no attributes" do
      lambda{ HumanBeing.new }.should_not raise_error
    end
    
    describe 'provides an attributes interface which' do
      before :each do
        @li_piao = HumanBeing.new( :profession => 'Natural Magician', :enhanced_by => 'Kai Wren')
      end
      
      it "should fail when getter methods for attributes that don't exist are invoked" do
        lambda{ @li_piao.ooga }.should raise_error(NoMethodError)
      end

      it "should provide getter methods for attributes" do
        @li_piao.profession.should == 'Natural Magician'
        @li_piao.enhanced_by.should == 'Kai Wren'
      end

      it "should respond to getter methods for attributes" do
        @li_piao.should respond_to(:profession)
        @li_piao.should respond_to(:enhanced_by)
      end

      it "should not respond to getter methods for attributes that don't exist" do
        @li_piao.should_not respond_to(:gods)
      end

      it "should create a setter method when one is invoked for attributes that don't exist" do
        @li_piao.niece = 'Li Plum'
        @li_piao.instance_variable_get('@attributes')[:niece].should == 'Li Plum'
        @li_piao.niece.should == 'Li Plum'
      end

      it "should provide setter methods for attributes" do
        @li_piao.enhanced_by = 'He of the Towers of Light'
        @li_piao.instance_variable_get('@attributes')[:enhanced_by].should == 'He of the Towers of Light'
      end

      it "should respond to setter methods for attributes" do
        @li_piao.should respond_to(:profession=)
        @li_piao.should respond_to(:enhanced_by=)
      end

      it "should not respond to setter methods for attributes that don't exist" do
        @li_piao.should_not respond_to(:god=)
      end

      it "should fail when query methods for attributes that don't exist are invoked" do
        lambda{ @li_piao.ooga? }.should raise_error(NoMethodError)
      end

      it "should provide query methods for attributes" do
        li_piao = HumanBeing.new( :profession => 'Natural Magician', :enhanced_by => nil)
        li_piao.profession?.should be_true
        li_piao.enhanced_by?.should be_false
      end

      it "should respond to query methods for attributes" do
        @li_piao.should respond_to(:profession?)
        @li_piao.should respond_to(:enhanced_by?)
      end

      it "should not respond to query methods for attributes that don't exist" do
        @li_piao.should_not respond_to(:theronic?)
      end
    end
  end
end
