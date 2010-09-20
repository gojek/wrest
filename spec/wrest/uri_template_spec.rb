# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require "spec_helper"

module Wrest
  describe Wrest::UriTemplate do
    it "should not maintain a reference to the string it is initialized with" do
      url_pattern = "http://localhost:3000/:resource/:id.:format"
      template = UriTemplate.new(url_pattern)
      url_pattern.gsub!(':', '!')
      template.uri_pattern.should == "http://localhost:3000/:resource/:id.:format"
    end

    it "should know how to build a Wrest::Uri from the pattern given a set of replacement options" do
      template = UriTemplate.new("http://localhost:3000/:resource/:id.:format")
      template.to_uri(
          :resource => 'shen_coins', :id => 5, :format => :json
        ).should == "http://localhost:3000/shen_coins/5.json".to_uri
    end
    
    it "should also handle username and password" do
      template = UriTemplate.new("http://:user::password@coathangers.com/:resource/:id")
      template.to_uri(
        :user => 'kaiwren',
        :password => 'fupuppies',
        :resource => 'portal',
        :id => '1'
      ).should == "http://kaiwren:fupuppies@coathangers.com/portal/1".to_uri
    end

    describe 'equals' do
      it "should have the same uri_pattern " do
        UriTemplate.new("http://localhost:3000/:resource/:id.:format").should_not ==  UriTemplate.new("http://localhost:3000/:id/:resource.:format")
        UriTemplate.new("http://localhost:3000/:resource/:id.:format").should ==  UriTemplate.new("http://localhost:3000/:resource/:id.:format")
      end
    end
    
    context 'extension' do
      it "should know how to build a new UriTemplate from an existing one by appending a path" do
        UriTemplate.new('http://localhost:3000')['/ooga/booga'].should == UriTemplate.new('http://localhost:3000/ooga/booga')
      end

      it "should know how to extend a UriTemplate that already has a path" do
        UriTemplate.new('http://localhost:3000/1')['/ooga/booga'].should == UriTemplate.new('http://localhost:3000/1/ooga/booga')
        UriTemplate.new('http://localhost:3000/1')['ooga/booga'].should == UriTemplate.new('http://localhost:3000/1/ooga/booga')
        UriTemplate.new('http://localhost:3000/1/')['/ooga/booga'].should == UriTemplate.new('http://localhost:3000/1/ooga/booga')

        UriTemplate.new('http://localhost:3000/1')[':ooga/booga'].should == UriTemplate.new('http://localhost:3000/1/:ooga/booga')
        UriTemplate.new('http://localhost:3000/1')[':ooga/booga'].should == UriTemplate.new('http://localhost:3000/1/:ooga/booga')
        UriTemplate.new('http://localhost:3000/1/')[':ooga/booga'].should == UriTemplate.new('http://localhost:3000/1/:ooga/booga')
      end
      
      it "should handle / positions with wisdom" do
        UriTemplate.new('http://localhost:3000/')['/ooga/booga'].should == UriTemplate.new('http://localhost:3000/ooga/booga')
        UriTemplate.new('http://localhost:3000')['/ooga/booga'].should == UriTemplate.new('http://localhost:3000/ooga/booga')
        UriTemplate.new('http://localhost:3000/')['ooga/booga'].should == UriTemplate.new('http://localhost:3000/ooga/booga')
        UriTemplate.new('http://localhost:3000')['ooga/booga'].should == UriTemplate.new('http://localhost:3000/ooga/booga')
      end
    end
    

  end
end
