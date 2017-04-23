# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require "spec_helper"

module Wrest
  describe Wrest::Uri do
    it "should respond to the five http actions" do
      uri = Uri.new('http://localhost')
      uri.should respond_to(:get)
      uri.should respond_to(:post)
      uri.should respond_to(:put)
      uri.should respond_to(:patch)
      uri.should respond_to(:delete)
    end

    it "should handle URIs" do
      Uri.new('https://localhost:3000').should == Uri.new(URI.parse('https://localhost:3000'))
    end

    it "should know when it is https" do
      Uri.new('https://localhost:3000').should be_https
    end

    context 'UriTemplate' do
      it "should be able to create a UriTemplate given a uri" do
        "http://localhost:3000".to_uri.to_template('/user/:name').should == UriTemplate.new("http://localhost:3000/user/:name")
      end

      it "should pass options to the uriTemplate being built" do
        "http://localhost:3000".to_uri(:name => 'abc').to_template('/user/:name').to_uri.should == "http://localhost:3000/user/abc".to_uri
      end

      it "should handle / positions with wisdom while creating UriTemplate from a given Uri" do
        "http://localhost:3000/".to_uri.to_template('/user/:name').should == UriTemplate.new("http://localhost:3000/user/:name")
        "http://localhost:3000".to_uri.to_template('/user/:name').should == UriTemplate.new("http://localhost:3000/user/:name")
        "http://localhost:3000/".to_uri.to_template('user/:name').should == UriTemplate.new("http://localhost:3000/user/:name")
        "http://localhost:3000".to_uri.to_template('user/:name').should == UriTemplate.new("http://localhost:3000/user/:name")
      end
    end

    it "should know when it is not https" do
      Uri.new('http://localhost:3000').should_not be_https
    end

    context 'extension' do
      it "should know how to build a new uri from an existing one by appending a path" do
        Uri.new('http://localhost:3000')['/ooga/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
      end

      it "should not lose bits of the path along the way" do
        Uri.new('http://localhost:3000/ooga')['/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
      end

      it "should handle / positions with wisdom" do
        Uri.new('http://localhost:3000/')['/ooga/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
        Uri.new('http://localhost:3000')['/ooga/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
        Uri.new('http://localhost:3000/')['ooga/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
        Uri.new('http://localhost:3000')['ooga/booga'].should == Uri.new('http://localhost:3000/ooga/booga')
      end
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

        Uri.new('http://localhost:3000?owner=kai&type=bottle').should_not == Uri.new('http://localhost:3000/')
        Uri.new('http://localhost:3000?owner=kai&type=bottle').should_not == Uri.new('http://localhost:3000?')
        Uri.new('http://localhost:3000?owner=kai&type=bottle').should_not == Uri.new('http://localhost:3000?type=bottle&owner=kai')

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
      let(:original) { Uri.new('http://localhost:3000/ooga', :default_headers => { H::ContentType => T::FormEncoded }) }
      let(:clone) { original.clone }

      it "should be equal to its clone" do
        original.should eq(clone)
      end

      it "should not be the same object as the clone" do
        original.should_not be_equal(clone)
      end

      it "should allow options to be changed when building the clone" do
        clone = original.clone(:username => 'kaiwren', :password => 'bottle')
        original.should_not == clone
        clone.username.should == 'kaiwren'
        clone.password.should == 'bottle'
        original.username.should be_nil
      end

      context "default headers" do
        it "merges the default headers" do
          original.clone(:default_headers => { H::Connection => T::KeepAlive }).default_headers.should eq(
          H::Connection => T::KeepAlive,
          H::ContentType => T::FormEncoded
          )
        end

        it "ensures incoming defaults have priority" do
          original.clone(:default_headers => { H::ContentType => T::ApplicationXml }).default_headers.should eq(
          H::ContentType => T::ApplicationXml
          )
        end
      end
    end

    describe 'HTTP actions' do
      def setup_http
        http = double(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).and_return(http)
        http.should_receive(:read_timeout=).with(60)
        http.should_receive(:set_debug_output).with(nil)
        http
      end

      context "GET" do
        it "should know how to get" do
          uri = "http://localhost:3000/glassware".to_uri

          http = setup_http

          request = Net::HTTP::Get.new('/glassware', {})
          Net::HTTP::Get.should_receive(:new).with('/glassware', {}).and_return(request)

          http.should_receive(:request).with(request, nil).and_return(build_ok_response)

          uri.get
        end
        context "query parameters" do
          it "should know how to get with parameters" do
            uri = "http://localhost:3000/glassware".to_uri

            http = setup_http

            request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
            Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response)

            uri.get(build_ordered_hash([[:owner, 'Kai'],[:type, 'bottle']]), :page => '2', :per_page => '5')
          end

          it "should know how to get with parameters included in the uri" do
            uri = "http://localhost:3000/glassware?owner=Kai&type=bottle".to_uri

            http = setup_http

            request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
            Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response)

            uri.get({}, :page => '2', :per_page => '5')
          end

          it "should propagate http auth options while being converted to Template and back" do
            base = "http://localhost:3000/".to_uri(:username => 'ooga', :password => 'bar')
            template = base.to_template('/search/:search')
            uri = template.to_uri(:search => 'kaiwren')
            request = Wrest::Native::Get.new(uri, {}, {} ,{:username => "ooga", :password =>"bar"})
            expect(Http::Get).to receive(:new).with(uri,{},{},{:username => "ooga", :password =>"bar"}).and_return(request)

            http_request = double(Net::HTTP::Get, :method => "GET", :hash => {})
            http_request.should_receive(:basic_auth).with('ooga', 'bar')
            request.should_receive(:http_request).at_least(1).times.and_return(http_request)
            request.should_receive(:do_request).and_return(double(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))
            uri.get
          end


          it "should know how to get with a ? appended to the uri and no appended parameters" do
            uri = "http://localhost:3000/glassware?".to_uri

            http = setup_http

            request = Net::HTTP::Get.new('/glassware', {'page' => '2', 'per_page' => '5'})
            Net::HTTP::Get.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response)

            uri.get({}, :page => '2', :per_page => '5')
          end

          it "should know how to get with a ? appended to the uri and specified parameters" do
            uri = "http://localhost:3000/glassware?".to_uri

            http = setup_http

            request = Net::HTTP::Get.new('/glassware?owner=kai&type=bottle', {'page' => '2', 'per_page' => '5'})

            Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response)

            uri.get(build_ordered_hash([[:owner, 'Kai'],[:type, 'bottle']]), :page => '2', :per_page => '5')
          end

          it "should know how to get with parameters appended to the uri and specfied parameters" do
            uri = "http://localhost:3000/glassware?owner=kai&type=bottle".to_uri

            http = setup_http

            request = Net::HTTP::Get.new('/glassware?owner=kai&type=bottle&param1=one&param2=two', {'page' => '2', 'per_page' => '5'})

            Net::HTTP::Get.should_receive(:new).with('/glassware?owner=kai&type=bottle&param1=one&param2=two', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response)

            uri.get(build_ordered_hash([[:param1, 'one'],[:param2, 'two']]), :page => '2', :per_page => '5')
          end

          it "should know how to get with parameters but without any headers" do
            uri = "http://localhost:3000/glassware".to_uri

            http = setup_http

            request = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {})
            Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response)

            uri.get(build_ordered_hash([[:owner, 'Kai'],[:type, 'bottle']]))
          end
        end
      end

      it "should know how to post" do
        uri = "http://localhost:3000/glassware".to_uri

        http = setup_http

        request = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Post.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

        http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
      end

      it "should know how to post form-encoded parameters using Uri#post_form" do
        uri = "http://localhost:3000/glassware".to_uri

        http = setup_http

        request = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Post.should_receive(:new).with('/glassware',
        'page' => '2', 'per_page' => '5', H::ContentType=>T::FormEncoded
        ).and_return(request)

        http.should_receive(:request).with(request, "foo=bar&ooga=booga").and_return(build_ok_response)
        uri.post_form(build_ordered_hash([[:foo, 'bar'],[:ooga, 'booga']]), :page => '2', :per_page => '5')
      end

      it "should know how to put" do
        uri = "http://localhost:3000/glassware".to_uri

        http = setup_http

        request = Net::HTTP::Put.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Put.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

        http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.put '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
      end

      context "PATCH" do
        it "should know how to patch" do
          uri = "http://localhost:3000/glassware".to_uri

          http = setup_http

          request = Net::HTTP::Patch.new('/glassware', {'page' => '2', 'per_page' => '5'})
          Net::HTTP::Patch.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

          http.should_receive(:request).with(request, '<ooga>Booga</ooga>').and_return(build_ok_response)

          uri.patch '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
        end
      end

      context "DELETE" do

        it "should know how to delete" do
          uri = "http://localhost:3000/glassware".to_uri

          http = setup_http

          request = Net::HTTP::Delete.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
          Net::HTTP::Delete.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

          http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

          uri.delete(build_ordered_hash([[:owner, 'Kai'],[:type, 'bottle']]), :page => '2', :per_page => '5')
        end

        context "query parameters" do
          it "should know how to delete with parameters included in the uri" do
            uri = "http://localhost:3000/glassware?owner=Kai&type=bottle".to_uri

            http = setup_http

            request = Net::HTTP::Delete.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
            Net::HTTP::Delete.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

            uri.delete({}, :page => '2', :per_page => '5')
          end

          it "should know how to delete with a ? appended to the uri and no appended parameters" do
            uri = "http://localhost:3000/glassware?".to_uri

            http = setup_http

            request = Net::HTTP::Delete.new('/glassware', {'page' => '2', 'per_page' => '5'})
            Net::HTTP::Delete.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

            uri.delete({}, :page => '2', :per_page => '5')

          end

          it "should know how to delete with a ? appended to the uri and specified parameters" do
            uri = "http://localhost:3000/glassware?".to_uri

            http = setup_http

            request = Net::HTTP::Delete.new('/glassware?owner=kai&type=bottle', {'page' => '2', 'per_page' => '5'})

            Net::HTTP::Delete.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request)


            http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

            uri.delete(build_ordered_hash([[:owner, 'Kai'],[:type, 'bottle']]), :page => '2', :per_page => '5')

          end

          it "should know how to delete with parameters appended to the uri and specfied parameters" do
            uri = "http://localhost:3000/glassware?owner=kai&type=bottle".to_uri

            http = setup_http

            request = Net::HTTP::Delete.new('/glassware?owner=kai&type=bottle', {'page' => '2', 'per_page' => '5'})

            Net::HTTP::Delete.should_receive(:new).with('/glassware?owner=kai&type=bottle&param1=one&param2=two', {'page' => '2', 'per_page' => '5'}).and_return(request)

            http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

            uri.delete(build_ordered_hash([[:param1, 'one'],[:param2, 'two']]), :page => '2', :per_page => '5')
          end
        end
      end

      it "should know how to ask for options on a URI" do
        uri = "http://localhost:3000/glassware".to_uri

        http = setup_http

        request = Net::HTTP::Options.new('/glassware')
        Net::HTTP::Options.should_receive(:new).with('/glassware', {}).and_return(request)

        http.should_receive(:request).with(request, nil).and_return(build_ok_response(nil))

        uri.options
      end

      it "should not mutate state of the uri across requests" do
        uri = "http://localhost:3000/glassware".to_uri

        http = double(Net::HTTP)
        Net::HTTP.should_receive(:new).with('localhost', 3000).at_least(1).times.and_return(http)
        http.should_receive(:read_timeout=).at_least(1).times.with(60)
        http.should_receive(:set_debug_output).at_least(1).times

        request_get = Net::HTTP::Get.new('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Get.should_receive(:new).with('/glassware?owner=Kai&type=bottle', {'page' => '2', 'per_page' => '5'}).and_return(request_get)

        request_post = Net::HTTP::Post.new('/glassware', {'page' => '2', 'per_page' => '5'})
        Net::HTTP::Post.should_receive(:new).with('/glassware', {'page' => '2', 'per_page' => '5'}).and_return(request_post)

        http.should_receive(:request).with(request_get, nil).and_return(build_ok_response)
        http.should_receive(:request).with(request_post, '<ooga>Booga</ooga>').and_return(build_ok_response)

        uri.get(build_ordered_hash([[:owner, 'Kai'],[:type, 'bottle']]), :page => '2', :per_page => '5')
        uri.post '<ooga>Booga</ooga>', :page => '2', :per_page => '5'
      end

      def setup_connection
        connection = double("Net::HTTP")
        response_200 = double(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {})
        allow(connection).to receive(:set_debug_output)
        allow(connection).to receive(:request).and_return(response_200)
        connection
      end

      http_methods = ["get", "delete", "post_multipart", "put_multipart"]
      http_methods.each do |http_method|
        context "#{http_method}" do
          before(:all) { require "wrest/multipart" }
          it "should call the given block with a Callback object" do
            connection = setup_connection
            uri = "http://localhost:3000/".to_uri
            allow(uri).to receive(:create_connection).and_return(connection)
            callback_called = false
            uri.send(http_method.to_sym) do |callback|
              callback.should be_an_instance_of(Callback)
              callback_called = true
            end
            callback_called.should be_truthy
          end

          it "should execute the request callback after receiving a successful response" do
            connection = setup_connection
            on_ok = false
            uri = "http://localhost:3000/".to_uri
            allow(uri).to receive(:create_connection).and_return(connection)
            uri.send(http_method.to_sym) do |callback|
              callback.on_ok{|response| on_ok = true}
            end
            on_ok.should be_truthy
          end

          it "should execute the uri callback after receiving a successful response" do
            connection = setup_connection
            on_ok = false
            uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
            uri.stub(:create_connection).and_return(connection)
            uri.send(http_method.to_sym)
            on_ok.should be_truthy
          end

          it "should execute the uri callback after receiving a successful response on sub path" do
            connection = setup_connection
            on_ok = false
            base_uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
            uri = base_uri['glassware']
            uri.stub(:create_connection).and_return(connection)
            uri.send(http_method.to_sym)
            on_ok.should be_truthy
          end

          it "should execute both callbacks after the successful response is received" do
            connection = setup_connection
            on_ok = false
            another_ok = false
            uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
            uri.stub(:create_connection).and_return(connection)
            block = lambda do |callback|
              callback.on_ok{|response| another_ok = true }
            end
            uri.send(http_method.to_sym) do |callback|
              callback.on_ok{|response| another_ok = true }
            end
            on_ok.should be_truthy
            another_ok.should be_truthy
          end
        end
      end

      ["put", "post"].each do |http_method|
        context "#{http_method}" do
          context "Native API" do
            it "should yield callback object if a block is given for Uri::get" do
              connection = setup_connection
              uri = "http://localhost:3000/".to_uri
              allow(uri).to receive(:create_connection).and_return(connection)
              callback_called = false
              uri.send(http_method.to_sym) do |callback|
                callback.is_a?(Callback).should be_truthy
                callback_called = true
              end
              callback_called.should be_truthy
            end

            it "should execute the request callback after receiving a successful response" do
              connection = setup_connection
              on_ok = false
              uri = "http://localhost:3000/".to_uri
              allow(uri).to receive(:create_connection).and_return(connection)
              uri.send(http_method.to_sym) do |callback|
                callback.on_ok{|response| on_ok = true}
              end
              on_ok.should be_truthy
            end

            it "should execute the uri callback after receiving a successful response" do
              connection = setup_connection
              on_ok = false
              uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
              uri.stub(:create_connection).and_return(connection)
              uri.send(http_method.to_sym)
              on_ok.should be_truthy
            end

            it "should execute the uri callback after receiving a successful response on subpath" do
              connection = setup_connection
              on_ok = false
              base_uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
              uri = base_uri['glassware']
              uri.stub(:create_connection).and_return(connection)
              uri.send(http_method.to_sym)
              on_ok.should be_truthy
            end

            it "should execute both callbacks after the successful response is received" do
              connection = setup_connection
              on_ok = false
              another_ok = false
              uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
              uri.stub(:create_connection).and_return(connection)
              block = lambda do |callback|
                callback.on_ok {|response| another_ok = true}
              end
              uri.send(http_method.to_sym) do |callback|
                callback.on_ok {|response| another_ok = true}
              end
              on_ok.should be_truthy
              another_ok.should be_truthy
            end
          end
        end
      end

      context "post_form" do
        it "should call the given block with a Callback object" do
          connection = setup_connection
          uri = "http://localhost:3000/".to_uri
          allow(uri).to receive(:create_connection).and_return(connection)
          callback_called = false
          uri.post_form do |callback|
            expect(callback.is_a?(Callback)).to be_truthy
            callback_called = true
          end
          expect(callback_called).to be_truthy
        end

        it "should execute the request callback after receiving a successful response" do
          connection = setup_connection
          on_ok = false
          uri = "http://localhost:3000/".to_uri
          allow(uri).to receive(:create_connection).and_return(connection)
          request = Wrest::Native::Post.new(uri)
          uri.post_form do |callback|
            callback.on_ok{|response| on_ok = true}
          end
          expect(on_ok).to be_truthy
        end

        it "should execute the uri callback after receiving a successful response" do
          connection = setup_connection
          on_ok = false
          uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
          uri.stub(:create_connection).and_return(connection)
          uri.post_form
          expect(on_ok).to be_truthy
        end

        it "should execute the uri callback after receiving a successful response on sub path" do
          connection = setup_connection
          on_ok = false
          base_uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
          uri = base_uri['glassware']
          uri.stub(:create_connection).and_return(connection)
          uri.post_form
          expect(on_ok).to be_truthy
        end

        it "should execute both callbacks after the successful response is received" do
          connection = setup_connection
          on_ok = false
          another_ok = false
          uri = "http://localhost:3000/".to_uri(:callback => {200 => lambda{|response| on_ok = true}})
          uri.stub(:create_connection).and_return(connection)
          block = lambda do |callback|
            callback.on_ok{|response| another_ok = true}
          end
          uri.post_form do |callback|
            callback.on_ok{|response| another_ok = true}
          end
          expect(on_ok).to be_truthy
          expect(another_ok).to be_truthy
        end
      end

      context "default headers" do
        let(:oauth_header) { {'Authorization' => 'OAuth YOUR_ACCESS_TOKEN'} }
        let(:alternative_oauth_header) { {'Authorization' => 'OAuth YOUR_OTHER_ACCESS_TOKEN'} }
        let(:content_type_header) { {'Content-Type' => 'application/json'} }
        let(:uri) { 'http://ooga.com'.to_uri(:default_headers => oauth_header) }

        it "lets incoming default_headers take precedence when the Uri is extended" do
          uri['/foo', {:default_headers => content_type_header}].default_headers.should eq(content_type_header)
        end

        {
          'get' => {},
          'delete' => {},
          'post' => '',
          'put' => '',
        }.each do |verb, blank_first_param_value|
          context "#{verb.upcase}" do
            it "sets the default headers if there are no request headers" do
              uri.send("build_#{verb}").headers.should eq(oauth_header)
            end

            it "merges the default headers into the request headers" do
              uri.send("build_#{verb}", blank_first_param_value,
              content_type_header
              ).headers.should eq(oauth_header.merge(content_type_header))
            end

            it "lets the incoming headers take precedent over the defaults" do
              uri.send("build_#{verb}", blank_first_param_value, alternative_oauth_header).headers.should eq(alternative_oauth_header)
            end
          end
        end

        context "POST (form-encoded)" do
          it "sets the default headers if there are no request headers" do
            uri.build_post_form.headers.should eq(oauth_header.merge(Wrest::H::ContentType => Wrest::T::FormEncoded))
          end

          it "merges the default headers into the request headers" do
            uri.build_post_form({}, content_type_header).headers.should eq(
            oauth_header.merge(content_type_header).merge(Wrest::H::ContentType => Wrest::T::FormEncoded)
            )
          end

          it "lets the incoming headers take precedent over the defaults" do
            uri.build_post_form({}, alternative_oauth_header).headers.should eq(alternative_oauth_header.merge(Wrest::H::ContentType => Wrest::T::FormEncoded))
          end
        end
      end

      context "asynchronous", :functional => true do
        let(:hash){Hash.new}

        context "default backend" do
          it "should execute the request and the given callback on a separate thread by default" do
            uri = "http://localhost:3000/no_body".to_uri(:callback => {200 => lambda{|response| hash["success"] = true}})
            uri.get_async

            sleep 0.1
            hash.key?("success").should be_truthy
          end
        end

        asynchronous_backends = {"threads" => "default_to_threads!", "eventmachine" => "default_to_em!"}
        asynchronous_backends.each do |backend_type, backend_method|
          context "#{backend_type}" do
            before :each do
              Wrest::AsyncRequest.send(backend_method.to_sym)
            end

            context "GET" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/no_body".to_uri(:callback => {200 => lambda{|response| hash["success"] = true}})
                uri.get_async

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end

            context "PUT" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/not_found".to_uri(:callback => {404 => lambda{|response| hash["success"] = true}})
                uri.put_async

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end

            context "POST" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/nothing".to_uri(:callback => {200 => lambda{|response| hash["success"] = true}})
                uri.post_async

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end

            context "DELETE" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/not_found".to_uri(:callback => {404 => lambda{|response| hash["success"] = true}})
                uri.delete_async

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end

            context "POST FORM" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/not_found".to_uri(:callback => {404 => lambda{|response| hash["success"] = true}})
                uri.post_form_async

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end

            context "POST MULTIPART" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/uploads".to_uri(:callback => {200 => lambda{|response| hash["success"] = true}})
                file_name = File.expand_path("#{Wrest::Root}/../Rakefile")
                file = File.open(file_name)
                uri.post_multipart_async('file' => UploadIO.new(file, "text/plain", file_name), :calback => {200 => lambda{|response| hash["success"] = true}})

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end

            context "PUT MULTIPART" do
              it "should execute the request and the given callback" do
                uri = "http://localhost:3000/uploads/1".to_uri(:callback => {200 => lambda{|response| hash["success"] = true}})
                file_name = File.expand_path("#{Wrest::Root}/../Rakefile")
                file = File.open(file_name)
                uri.put_multipart_async('file' => UploadIO.new(file, "text/plain", file_name), :calback => {200 => lambda{|response| hash["success"] = true}})

                sleep 0.1
                hash.key?("success").should be_truthy
              end
            end
          end
        end
      end
    end
  end
end
