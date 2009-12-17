# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../spec_helper'

module Wrest
  describe Wrest::Uri do
    it "should respond to the four http actions" do
      uri = Uri.new('http://localhost')
      uri.should respond_to(:get)
      uri.should respond_to(:post)
      uri.should respond_to(:put)
      uri.should respond_to(:delete)
    end

    it "should know when it is https" do
      Uri.new('https://localhost:3000').should be_https
    end

    it "should know when it is not https" do
      Uri.new('http://localhost:3000').should_not be_https
    end

    it "should know how to build a new uri from an existing one by appending a path" do
      Uri.new('http://localhost:3000')['/ooga/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
    end

    it "should know its full path" do
      Uri.new('http://localhost:3000/ooga').full_path.should == '/ooga'
      Uri.new('http://localhost:3000/ooga?foo=meh&bar=1').full_path.should == '/ooga?foo=meh&bar=1'
    end
        
    it "should know its host" do
      Uri.new('http://localhost:3000/ooga').host.should == 'localhost'
    end

    it "should know its port" do
      Uri.new('http://localhost:3000/ooga').port.should == 3000
      Uri.new('http://localhost/ooga').port.should == 80
    end

    it "should include the username and password while building a new uri if no options are provided" do
      Uri.new(
        'http://localhost:3000', 
        :username => 'foo', 
        :password => 'bar')['/ooga/booga'].should == Uri.new(
                                                      'http://localhost:3000/ooga/booga', 
                                                      :username => 'foo', 
                                                      :password => 'bar')
    end
    
    it "should use the username and password provided while building a new uri if present" do
      uri = Uri.new('http://localhost:3000', :username => 'foo', :password => 'bar')
      uri.username.should == 'foo'
      uri.password.should == 'bar'
      
      extended_uri = uri['/ooga/booga', {:username => 'meh', :password => 'baz'}]
      extended_uri.username.should == 'meh'
      extended_uri.password.should == 'baz'
    end
    
    it "should know how to produce its uri as a string" do
      Uri.new('http://localhost:3000').uri_string.should == 'http://localhost:3000'
      Uri.new('http://localhost:3000').to_s.should == 'http://localhost:3000'
      Uri.new('http://localhost:3000', :username => 'foo', :password => 'bar').to_s.should == 'http://localhost:3000'
      Uri.new('http://foo:bar@localhost:3000').to_s.should == 'http://foo:bar@localhost:3000'
    end
    
    describe 'Equals' do
      it "should understand equality" do
        Uri.new('https://localhost:3000/ooga').should_not == nil
        Uri.new('https://localhost:3000/ooga').should_not == 'https://localhost:3000/ooga'
        Uri.new('https://localhost:3000/ooga').should_not == Uri.new('https://localhost:3000/booga')
        
        Uri.new('https://ooga:booga@localhost:3000/ooga').should_not == Uri.new('https://foo:bar@localhost:3000/booga')
        Uri.new('http://ooga:booga@localhost:3000/ooga').should_not == Uri.new('http://foo:bar@localhost:3000/booga')
        Uri.new('http://localhost:3000/ooga').should_not == Uri.new('http://foo:bar@localhost:3000/booga')
        
        Uri.new('https://localhost:3000').should_not == Uri.new('https://localhost:3500')
        Uri.new('https://localhost:3000').should_not == Uri.new('http://localhost:3000')
        Uri.new('http://localhost:3000', :username => 'ooga', :password => 'booga').should_not == Uri.new('http://ooga:booga@localhost:3000')
                
        Uri.new('http://localhost:3000').should == Uri.new('http://localhost:3000')
        Uri.new('http://localhost:3000', :username => 'ooga', :password => 'booga').should == Uri.new('http://localhost:3000', :username => 'ooga', :password => 'booga')
        Uri.new('http://ooga:booga@localhost:3000').should == Uri.new('http://ooga:booga@localhost:3000')
      end


      it "should have the same hash code if it is the same uri" do
        Uri.new('https://localhost:3000').hash.should == Uri.new('https://localhost:3000').hash
        Uri.new('http://ooga:booga@localhost:3000').hash.should == Uri.new('http://ooga:booga@localhost:3000').hash
        Uri.new('http://localhost:3000', :username => 'ooga', :password => 'booga').hash.should == Uri.new('http://localhost:3000', :username => 'ooga', :password => 'booga').hash
        
        Uri.new('https://localhost:3001').hash.should_not == Uri.new('https://localhost:3000').hash
        Uri.new('https://ooga:booga@localhost:3000').hash.should_not == Uri.new('https://localhost:3000').hash
        Uri.new('https://localhost:3000', :username => 'ooga', :password => 'booga').hash.should_not == Uri.new('https://localhost:3000').hash
        Uri.new('https://localhost:3000', :username => 'ooga', :password => 'booga').hash.should_not == Uri.new('http://localhost:3000', :username => 'foo', :password => 'bar').hash
      end
    end
    
    describe 'Cloning' do
      before :each do
        @original = Uri.new('http://localhost:3000/ooga')
        @clone = @original.clone        
      end
      
      it "should be equal to its clone" do
        @original.should == @clone
      end
      
      it "should not be the same object as the clone" do
        @original.should_not be_equal(@clone)
      end
      
      it "should allow options to be changed when building the clone" do
        clone = @original.clone(:username => 'kaiwren', :password => 'bottle')
        @original.should_not == clone
        clone.username.should == 'kaiwren'
        clone.password.should == 'bottle'
        @original.username.should be_nil
      end
    end
    
    describe 'HTTP actions' do
      def setup_http
        returning mock(Net::HTTP) do |http|
          Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)
          http.should_receive(:read_timeout=).with(60)
        end
      end
      
      it "should know how to get" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http

        request = Net::HTTP::Get.new('/glassware', {})
        Net::HTTP::Get.should_receive(:new).with('/glassware', {}).and_return(request)
        
        http.should_receive(:request).with(request, nil).and_return(build_ok_response)

        uri.get
      end

      it "should know how to get with parameters" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http
                
        request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)
        
        http.should_receive(:request).with(request, nil).and_return(build_ok_response)

        uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
      end

      it "should know how to get with parameters but without any headers" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http
        
        request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {})
        Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {}).and_return(request)
        
        http.should_receive(:request).with(request, nil).and_return(build_ok_response)

        uri.get(:owner => 'Kai', :type => 'bottle')
      end

      it "should know how to post" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http
      
        request = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Post.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)
      
        http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
      end
      
      it "should know how to post form-encoded parameters using Uri#post_form" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http

        request = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Post.should_receive(:new).with('/glassware', 
                                                  'page' => '2', 'per_page' => '5', H::ContentType=>T::FormEncoded
                                                  ).and_return(request)

        http.should_receive(:request).with(request, "foo=bar&ooga=booga").and_return(build_ok_response)
        params = ActiveSupport::OrderedHash.new
        params[:ooga] = 'booga'
        params[:foo] = 'bar'
        uri.post_form(params, :page => '2', :per_page => '5')
      end

      it "should know how to put" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http
              
        request = Net::HTTP::Put.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Put.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

        http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.put '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
      end

      it "should know how to delete" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http

        request = Net::HTTP::Delete.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Delete.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

        http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

        uri.delete({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
      end

      it "should know how to ask for options on a URI" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = setup_http

        request = Net::HTTP::Options.new('/glassware')
        Net::HTTP::Options.should_receive(:new).with('/glassware', {}).and_return(request)
      
        http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

        uri.options
      end

      it "should not mutate state of the uri across requests" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).any_number_of_times.and_return(http)
        http.should_receive(:read_timeout=).any_number_of_times.with(60)
      
        request_get = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request_get)
      
        request_post = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Post.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request_post)
      
        http.should_receive(:request).with(request_get, nil).and_return(build_ok_response)
        http.should_receive(:request).with(request_post, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
        uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
      end
    end  
  end
end
