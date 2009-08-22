# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Components
  describe Mutators::Base do
    it "should raise an exception if mutate is invoked without do_mutate being implemented in a subclass" do
      lambda{ Class.new(Mutators::Base).new.mutate([]) }.should raise_error(Wrest::Exceptions::MethodNotOverridden)
    end

    it "should ensure that the next mutator is invoked for a subclass" do
      next_mutator = mock('Mutator')
      mutator = Mutators::CamelToSnakeCase.new(next_mutator)

      next_mutator.should_receive(:mutate).with(['a', 1]).and_return([:a, '1'])

      mutator.mutate(['a', 1]).should == [:a, '1']
    end

    it "should know how to chain mutators recursively" do
      mutator = Mutators::XmlSimpleTypeCaster.new(Mutators::CamelToSnakeCase.new)
      mutator.mutate(
      ["Result", [{
        "Publish-Date"=>["1240326000"],
        "News-Source"=>[{"Online" => ["PC via News"], "Unique-Id" => [{"type"=>"integer", "content"=>"1"}]}]
      }]]
      ).should == ["result", {"publish_date" => "1240326000", "news_source" => {"online"=>"PC via News", "unique_id"=>1}}]
    end
    
    it "should register all subclasses in the registry" do
      class SomeMutator < Mutators::Base; end
      Mutators::REGISTRY[:some_mutator].should == SomeMutator
    end
  end
end
