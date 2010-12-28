# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

require "spec_helper"

describe Hash, 'conversions' do
  it "should know how to build a mutated hash given a hash mutator" do
    class StringToSymbolMutator < Wrest::Components::Mutators::Base
      def mutate(pair)
        [pair.first.to_sym, pair.last]
      end
    end
    
    {'ooga' => 'booga'}.mutate_using(StringToSymbolMutator.new).should == {:ooga => 'booga'}
  end

  it "should know how to convert the keys of a hash into an array" do
    {
      "a" => "-a-",
      100 => "-100-",
      100..102 => "-100 to 102-",
      999..1000 => "-999 to 1000-"
    }.keys_to_array.should == {
      ["a"] => "-a-",
      [100] => "-100-",
      [100, 101, 102] => "-100 to 102-",
      [999,1000] => "-999 to 1000-"
    }
  end
end
