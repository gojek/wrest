# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../spec_helper'

describe Wrest::Native::Request do
  it "should convert all symbols in header keys to strings" do
    Wrest::Native::Request.new(
                'http://localhost/foo'.to_uri, Net::HTTP::Get, {}, 
                nil, 'Content-Type' => 'application/xml', :per_page => '10'
                ).headers.should == {
                  'Content-Type' => 'application/xml',
                  'per_page' => '10'
                }
  end
  
  it "should default the 'follow_redirects' option to true for a Get" do
    Wrest::Native::Get.new('http://localhost/foo'.to_uri).follow_redirects.should be_true
  end
  
  it "should default the 'follow_redirects_count' option to 0" do
    Wrest::Native::Get.new('http://localhost/foo'.to_uri).follow_redirects_count.should == 0
  end
  
  it "should default the 'follow_redirects_limit' option to 5" do
    Wrest::Native::Get.new('http://localhost/foo'.to_uri).follow_redirects_limit.should == 5
  end
  
  it "should allow Gets to disable redirect follows" do
    Wrest::Native::Get.new('http://localhost/foo'.to_uri, {}, {}, {:follow_redirects => false}).follow_redirects.should be_false
  end
  
  it "should increment the follow_redirects_count for every redirect leving the count unaffected in previous requests" do
    uri = 'http://localhost/foo'.to_uri
    request = Wrest::Native::Get.new(uri)
    redirect_location = 'http://coathangers.com'
    redirected_request = mock('Request to http://coathangers.com')

    mock_connection = mock('Http Connection')
    uri.stub!(:create_connection).and_return(mock_connection)
    
    raw_response = mock(Net::HTTPRedirection)
    raw_response.stub!(:code).and_return('301')
    raw_response.stub!(:message).and_return('')
    raw_response.stub!(:body).and_return('')
    raw_response.stub!(:[]).with('location').and_return(redirect_location)
    
    response = Wrest::Native::Redirection.new(raw_response)
    
    mock_connection.should_receive(:request).and_return(raw_response)
    
    Wrest::Native::Response.should_receive(:new).and_return(response)
    redirected_request.stub!(:get)
    redirect_location.should_receive(:to_uri).with(hash_including(:follow_redirects_count=>1)).and_return(redirected_request)
    
    request.invoke
    request.follow_redirects_count.should == 0
  end
  
  it "should default the 'follow_redirects' option to false for a Post, Put or Delete" do
    Wrest::Native::Post.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
    Wrest::Native::Put.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
    Wrest::Native::Delete.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
  end  
end
