# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

require File.dirname(__FILE__) + '/../../../spec_helper'

describe String, 'conversions' do
  it "should know how to convert a string to a Wrest::Uri" do
    'http://localhost:3000'.to_uri.should == Wrest::Uri.new('http://localhost:3000')
  end
  
  it "should accept username and password as options" do
    uri = 'http://localhost:3000'.to_uri(
      :username => 'ooga',
      :password => 'booga'
    )
    uri.username.should == 'ooga'
    uri.password.should == 'booga'
  end
  
  it "should strip leading spaces from a uri before building it" do
    ' http://localhost:3000'.to_uri.should == Wrest::Uri.new('http://localhost:3000')
  end
  
  it "should strip trailing spaces from a uri before building it" do
    'http://localhost:3000  '.to_uri.should == Wrest::Uri.new('http://localhost:3000')
  end
  
  it "should levae the original string  unchanged after building a uri from it" do
    url = ' http://localhost:3000  '
    url.to_uri.should == Wrest::Uri.new('http://localhost:3000')
    url.should == ' http://localhost:3000  '
  end
end
