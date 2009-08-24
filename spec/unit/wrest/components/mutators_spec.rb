# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest::Components
  describe Mutators do
    it "should know how to chain mutators without having to namespace them all" do
      mutator = Mutators.chain(:xml_mini_type_caster, :xml_simple_type_caster, :camel_to_snake_case)
      mutator.class.should == Mutators::XmlMiniTypeCaster
      mutator.next_mutator.class.should == Mutators::XmlSimpleTypeCaster
      mutator.next_mutator.next_mutator.class.should == Mutators::CamelToSnakeCase
    end
  end
end
