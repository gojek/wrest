# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../spec_helper'

describe Wrest::Http::Request do
  it "should convert all symbols in header keys to strings" do
    Wrest::Http::Request.new(
                'http://localhost/foo'.to_uri, Net::HTTP::Get, {}, 
                nil, 'Content-Type' => 'application/xml', :per_page => '10'
                ).headers.should == {
                  'Content-Type' => 'application/xml',
                  'per_page' => '10'
                }
  end
  
  it "should default the 'follow_redirects' option to true for a Get" do
    Wrest::Http::Get.new('http://localhost/foo'.to_uri).follow_redirects.should be_true
  end
  
  it "should allow Gets to disable redirect follows" do
    Wrest::Http::Get.new('http://localhost/foo'.to_uri, {}, {}, {:follow_redirects => false}).follow_redirects.should be_false
  end
  
  it "should default the 'follow_redirects' option to false for a Post, Put or Delete" do
    Wrest::Http::Post.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
    Wrest::Http::Put.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
    Wrest::Http::Delete.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
  end
end
