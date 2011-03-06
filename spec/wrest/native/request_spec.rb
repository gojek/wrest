# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require "spec_helper"

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

    response = Wrest::Native::Redirection.new(raw_response)
    response.stub!(:[]).with('location').and_return(redirect_location)

    mock_connection.should_receive(:request).and_return(raw_response)
    mock_connection.should_receive(:set_debug_output)
    
    Wrest::Native::Response.should_receive(:new).and_return(response)
    redirected_request.stub!(:get)
    Wrest::Uri.should_receive(:new).with(redirect_location, hash_including(:follow_redirects_count=>1)).and_return(redirected_request)
    
    request.invoke
    request.follow_redirects_count.should == 0
  end
  
  it "should not set basic authentication for request if either of username or password is nil" do
    uri = 'http://localhost/foo'.to_uri
    request = Wrest::Native::Get.new(uri)
    http_request = mock(Net::HTTP::Get, :method => "GET", :hash => {})
    http_request.should_not_receive(:basic_auth)
    request.should_receive(:http_request).any_number_of_times.and_return(http_request)
    request.should_receive(:do_request).and_return(mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))
    request.invoke
  end

  it "should set basic authentication for request" do
    uri = 'http://localhost/foo'.to_uri
    request = Wrest::Native::Get.new(uri, {}, {}, {:username => "name", :password => "password"})
    http_request = mock(Net::HTTP::Get, :method => "GET", :hash => {})
    http_request.should_receive(:basic_auth).with('name', 'password')
    request.should_receive(:http_request).any_number_of_times.and_return(http_request)
    request.should_receive(:do_request).and_return(mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))
    request.invoke
  end

  it "should default the 'follow_redirects' option to false for a Post, Put or Delete" do
    Wrest::Native::Post.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
    Wrest::Native::Put.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
    Wrest::Native::Delete.new('http://localhost/foo'.to_uri).follow_redirects.should_not be_true
  end
  
  context "SSL options" do
    let(:uri){ 'https://localhost/foo'.to_uri }
    let(:http_request){ mock(Net::HTTP::Get, :method => "GET") }
    def setup_request_expectations(request)
      request.tap do |r|
        request.should_receive(:http_request).any_number_of_times.and_return(http_request)
        request.should_receive(:do_request).and_return(mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))
      end
    end
    
    it "should have verification mode for https set to VERIFY_PEER by default" do
      request = setup_request_expectations(Wrest::Native::Get.new(uri, {}, {}))

      request.invoke
      request.connection.verify_mode.should == OpenSSL::SSL::VERIFY_PEER
    end
   
    it "should have verification mode for https set to VERIFY_NONE when passed as an option" do
      request = setup_request_expectations(Wrest::Native::Get.new(uri, {}, {}, :verify_mode => OpenSSL::SSL::VERIFY_NONE))
      
      request.invoke
      request.connection.verify_mode.should == OpenSSL::SSL::VERIFY_NONE
    end

    it "should have the certificate authority path set when the ca_path option is passed" do
      request = setup_request_expectations(Wrest::Native::Get.new(uri, {}, {}, :ca_path => '/etc/ssl/certs'))
      
      request.invoke
      request.connection.ca_path.should == '/etc/ssl/certs'
    end
  end
  
  it "should not store response in cache if the original request was not GET" do
    cache = {}
    post = Wrest::Native::Post.new("http://localhost".to_uri, {}, {}, cacheable_headers, {:cache_store => cache})
    post.should_receive(:do_request).and_return(mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))

    cache.should_not_receive(:[])
    post.invoke
  end

  context "callbacks" do
    it "should run the appropriate callbacks" do
      cb = mock
      cb.should_receive(:cb_204)
      cb.should_receive(:cb_200)
      cb.should_receive(:cb_range)

      response_handler = Wrest::Callback.new({
        200 => lambda { |response| cb.cb_200 },
        204 => lambda { |response| cb.cb_204},
        500..599 => lambda { |response| cb.cb_range}
      })

      uri = 'http://localhost/foo'.to_uri
      request = Wrest::Native::Get.new(uri,{},{},:callback => response_handler)

      response_204 = mock(Net::HTTPOK, :code => "204", :message => 'not OK', :body => '', :to_hash => {})
      response_200 = mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {})
      response_501 = mock(Net::HTTPOK, :code => "501", :message => 'not implemented', :body => '', :to_hash => {})

      request.should_receive(:do_request).and_return(response_200, response_501, response_204)

      request.invoke
      request.invoke
      request.invoke
    end
  end

  context "functional", :functional => true do
    it "should have a empty string for a body" do
      Wrest::Native::Request.new('http://localhost:3000/lead_bottles/1.xml'.to_uri, Net::HTTP::Get).invoke.body.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<lead-bottle>\n  <id type=\"integer\">1</id>\n  <name>Wooz</name>\n  <universe-id type=\"integer\" nil=\"true\"></universe-id>\n</lead-bottle>\n"
    end

    it "should correctly use the detailed_http_logging option" do
      logger = mock(Logger)
      logger.should_receive(:<<).at_least(:once).with {|detailed_log| detailed_log.include? "opening connection to"}
      logger.should_receive(:<<).any_number_of_times

      uri = "http://localhost:3000/glassware".to_uri :detailed_http_logging => logger

      uri.get
    end

    
    it "should raise a Wrest exception on timeout" do
      lambda{ 
        Wrest::Native::Request.new('http://localhost:3000/two_seconds'.to_uri, Net::HTTP::Get, {}, '', {}, :timeout => 1).invoke 
        }.should raise_error(Wrest::Exceptions::Timeout)
    end
  end
end
