require File.dirname(__FILE__) + '/../spec_helper'

module Wrest
  describe Uri do
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

    it "should understand equality" do
      Uri.new('https://localhost:3000/ooga').should_not == 'https://localhost:3000/ooga'
      Uri.new('https://localhost:3000/ooga').should_not == Uri.new('https://localhost:3000/booga')
      Uri.new('https://localhost:3000').should_not == Uri.new('https://localhost:3500')
      Uri.new('https://localhost:3000').should_not == Uri.new('http://localhost:3000')
      Uri.new('http://localhost:3000').should == Uri.new('http://localhost:3000')
    end
    
    
    it "should have the same hash code if it is the same uri" do
      Uri.new('https://localhost:3000').hash.should == Uri.new('https://localhost:3000').hash
      Uri.new('https://localhost:3001').hash.should_not == Uri.new('https://localhost:3000').hash
    end
    
    describe 'Get' do
      it "should know how to get" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

        http.should_receive(:get).with('/glassware', {}).and_return(build_ok_response)

        uri.get
      end

      it "should know how to get with parameters" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

        http.should_receive(:get).with('/glassware?owner=Kai&type=bottle', 'page' => '2', 'per_page' => '5').and_return(build_ok_response)

        uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
      end

      it "should know how to get with parameters but without any headers" do
        uri = "http://localhost:3000/glassware".to_uri
        uri.should_not be_https

        http = mock(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

        http.should_receive(:get).with('/glassware?owner=Kai&type=bottle', {}).and_return(build_ok_response)

        uri.get(:owner => 'Kai', :type => 'bottle')
      end
    end
    
    it "should know how to post" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      http.should_receive(:post).with('/glassware', '<ooga>Booga</ooga>', {'page' => '2', 'per_page' => '5'}).and_return(build_ok_response)

      uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
    end

    it "should know how to put" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      http.should_receive(:put).with('/glassware', '<ooga>Booga</ooga>', {'page' => '2', 'per_page' => '5'}).and_return(build_ok_response)

      uri.put '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
    end

    it "should know how to delete" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)

      http.should_receive(:delete).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(build_ok_response(nil))

      uri.delete({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
    end

    it "should not mutate state of the uri across requests" do
      uri = "http://localhost:3000/glassware".to_uri
      uri.should_not be_https

      http = mock(Net::HTTP)
      Net::HTTP.should_receive(:new).with('localhost', 3000).any_number_of_times.and_return(http)

      http.should_receive(:get).with('/glassware?owner=Kai&type=bottle', 'page' => '2', 'per_page' => '5').and_return(build_ok_response)
      http.should_receive(:post).with('/glassware', '<ooga>Booga</ooga>', {'page' => '2', 'per_page' => '5'}).and_return(build_ok_response)

      uri.get({:owner => 'Kai', :type => 'bottle'}, :page => '2', :per_page => '5')
      uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
    end
  end
end
