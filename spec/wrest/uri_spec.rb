require File.dirname(__FILE__) + '/../spec_helper'

module Wrest
  describe Wrest::Uri do
    def build_ok_response(body = '')
      returning mock(Net::HTTPOK) do |response|
        response.stub!(:code).and_return('200')
        response.stub!(:message).and_return('OK')
        response.stub!(:body).and_return(body)
      end
    end

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
    
    describe 'Get' do
      it "should know how to get" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

        request = Net::HTTP::Get.new('/glassware', {})
        Net::HTTP::Get.should_receive(:new).with('/glassware', {}).and_return(request)
        
        http.should_receive(:request).with(request).and_return(build_ok_response)

        uri.get
      end

      it "should know how to get with parameters" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)
        
        request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)
        
        http.should_receive(:request).with(request).and_return(build_ok_response)

        uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
      end

      it "should know how to get with parameters but without any headers" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

        request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {})
        Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {}).and_return(request)
        
        http.should_receive(:request).with(request).and_return(build_ok_response)

        uri.get(:owner => 'Kai', :type => 'bottle')
      end
    end

    it "should know how to post" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      request = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
      Net::HTTP::Post.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)
      
      http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

      uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
    end

    it "should know how to put" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)
      
      request = Net::HTTP::Put.new('/glassware', {'page' => '2', 'per_page' => '5'})
      Net::HTTP::Put.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

      http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

      uri.put '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
    end

    it "should know how to delete" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      request = Net::HTTP::Delete.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
      Net::HTTP::Delete.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

      http.should_receive(:request).with(request).and_return(build_ok_response(nil))

      uri.delete({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
    end

    it "should know how to ask for options on a URI" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      request = Net::HTTP::Options.new('/glassware')
      Net::HTTP::Options.should_receive(:new).with('/glassware').and_return(request)
      
      http.should_receive(:request).with(request).and_return(build_ok_response(nil))

      uri.options
    end

    it "should not mutate state of the uri across requests" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).any_number_of_times.and_return(http)

      request_get = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
      Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request_get)
      
      request_post = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
      Net::HTTP::Post.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request_post)
      
      http.should_receive(:request).with(request_get).and_return(build_ok_response)
      http.should_receive(:request).with(request_post, '<ooga>Booga</ooga>').and_return(build_ok_response)

      uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
      uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
    end
  end
end
