# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../../spec_helper'

module Wrest::Components
  describe Mutators::XmlSimpleTypeCaster do
    before(:each) do
      @mutator = Mutators::XmlSimpleTypeCaster.new
    end

    # {"lead-bottle"=>[{"name"=>["Wooz"], "universe-id"=>[{"type"=>"integer", "nil"=>"true"}], "id"=>[{"type"=>"integer", "content"=>"1"}]}]}

    it "should typecast a nil value in a tuple" do
      @mutator.mutate(
      ["universe-id", [{"type"=>"integer", "nil"=>"true"}]]
      ).should == ["universe-id", nil]
    end

    it "should leave a string value in a tuple unchanged" do
      @mutator.mutate(
      ["name", ["Wooz"]]
      ).should == ["name", "Wooz"]
    end

    it "should cast an integer value in a tuple" do
      @mutator.mutate(
      ["id", [{"type"=>"integer", "content"=>"1"}]]
      ).should == ["id", 1]
    end
    
    it "should step into a value if it is a hash" do
      @mutator.mutate(
        ["Result", [{
                      "PublishDate"=>["1240326000"], 
                      "NewsSource"=>[{"Online" => ["PC via News"], "UniqueId" => [{"type"=>"integer", "content"=>"1"}]}]
                    }]]
      ).should == ["Result", {"PublishDate" => "1240326000", "NewsSource" => {"Online"=>"PC via News", "UniqueId"=>1}}]
    end
  end
end
