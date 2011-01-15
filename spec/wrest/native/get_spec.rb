require "spec_helper"
require 'rspec'

describe Wrest::Native::Get do

  before :each do
    @cache                            = Hash.new
    @request_uri                      = 'http://localhost/foo'.to_uri

    @get                              = Wrest::Native::Get.new(@request_uri, {}, {}, {:cache_store => @cache})
    @another_get_with_same_properties = Wrest::Native::Get.new(@request_uri, {}, {}, {:cache_store => @cache.clone}) # Use a different cache store, but it should not be considered when checking equality.
    @another_get_with_extra_parameter = Wrest::Native::Get.new(@request_uri, {:a_parameter => 10}, {}, {:cache_store => @cache})
  end

  describe "hashing and comparison" do
    it "should return true for equality between two identical Wrest::Get objects and their hashes" do
      @get.should == @get

      @get.should == @get.clone
      @get.hash.should == @get.clone.hash

      @get.should == @another_get_with_same_properties
      @get.hash.should == @another_get_with_same_properties.hash

      @get.should_not == @another_get_with_extra_parameter
      @get.hash.should_not == @another_get_with_extra_parameter.hash

      half_hour_after = (Time.now + (60*30)).httpdate
      ten_mins_early  = (Time.now - (10*30)).httpdate

      # All responses in the caching block returns a cacheable response by default
      headers         = {"Date" => Time.now.httpdate, "Expires" => half_hour_after, "Age" => 0, "Last-Modified" => ten_mins_early}

    end
  end

  describe "caching" do

    before :each do
      @ok_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers()))
      @get.stub!(:invoke_without_cache_check).and_return(@ok_response)
    end

    context "workflow - what happens when a GET request is made" do

      it "should check if response already exists in cache before making a request" do
        @cache.should_receive(:[]).with(@get.hash)
        @get.invoke
      end

      # When it is not in cache:
      it "should call invoke_without_cache_check to make a fresh request if response does not exist in cache" do
        @cache.should_receive(:[]).with(@get.hash).and_return(nil)
        @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
        @get.invoke
      end

      it "should cache the response after invoke makes a fresh request" do
        @cache.should_receive(:[]).and_return(nil)
        @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
        @cache.should_receive(:[]=).with(@get.hash, @ok_response)
        @get.invoke
      end


      # When already in cache:
      it "should not call invoke_without_cache_check if response exists in cache" do
        @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)
        @get.should_not_receive(:invoke_without_cache_check)
        @get.invoke
      end

      it "should check whether the cache entry has expired" do
        @cache.should_receive(:[]).and_return(@ok_response)
        @ok_response.should_receive(:expired?)
        @get.invoke
      end

      it "should use the cached response if it finds a matching one that hasn't expired" do
        @cached_response=Wrest::Native::Response.new(build_ok_response('', cacheable_headers())).tap { |h| h.headers["random"] = 123 }

        @cache.should_receive(:[]).with(@get.hash).and_return(@cached_response)
        @cached_response.should_receive(:expired?).and_return(false)

        @get.should_not_receive(:invoke_without_cache_check)
        @get.invoke.should == @cached_response
      end

      it "should check whether an expired cache entry can be validated" do
        @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

        @ok_response.should_receive(:expired?).and_return(true)
        @ok_response.should_receive(:can_be_validated?)

        @get.should_receive(:invoke_without_cache_check).and_return(nil)

        @get.invoke
      end

      describe "how to validate a cache entry" do
        before :all do
          @default_options =  {:follow_redirects=>true, :follow_redirects_count=>0, :follow_redirects_limit=>5}
        end

        it "should send an If-Not-Modified Get request if the cache has a Last-Modified" do
          @ok_response.should_receive(:expired?).and_return(true)
          @ok_response.can_be_validated?.should == true

          @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

          direct_get = Wrest::Native::Get.new(@request_uri)
          direct_get.should_receive(:invoke).and_return(@ok_response)

          Wrest::Native::Get.should_receive(:new).with(@request_uri, {}, {"if-modified-since" => @ok_response.headers["last-modified"]}, @default_options).and_return(direct_get)

          @get.invoke
        end
        it "should send an If-None-Match Get request if the cache has an ETag" do
          @ok_response.headers.delete "last-modified"
          @ok_response.headers["etag"]='123'

          @ok_response.should_receive(:expired?).and_return(true)
          @ok_response.can_be_validated?.should == true

          @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

          direct_get = Wrest::Native::Get.new(@request_uri)
          direct_get.should_receive(:invoke).and_return(@ok_response)

          Wrest::Native::Get.should_receive(:new).with(@request_uri, {}, {"if-none-match" => "123"}, @default_options).and_return(direct_get)

          @get.invoke
        end
      end

      describe "what happens when validating an expired cache entry" do
        before :each do
          one_day_back = (Time.now - 60*60*24).httpdate

          @cached_response=Wrest::Native::Response.new(build_ok_response('', cacheable_headers()))
          @cached_response.headers["random"] = 235
          @cached_response.headers["expires"]=one_day_back

          @cache.should_receive(:[]).with(@get.hash).and_return(@cached_response)
        end

        # 304 is Not Modified
        it "should use the cached response if the server returns 304" do
          not_modified_response = @ok_response.clone
          not_modified_response.should_receive(:code).any_number_of_times.and_return(304)

          @get.should_receive(:send_validation_request_for).and_return(not_modified_response)

          @get.invoke.should == @cached_response
        end

        it "should use it if the server returns a new response" do
          new_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers()))
          new_response.should_receive(:code).any_number_of_times.and_return(200)

          @get.should_receive(:send_validation_request_for).and_return(new_response)

          @get.invoke.should == new_response
        end

        it "should also cache it when the server returns a new response" do
          new_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers()))
          new_response.should_receive(:code).any_number_of_times.and_return(200)

          @get.should_receive(:send_validation_request_for).and_return(new_response)
          @cache.should_receive(:[]=).once

          @get.invoke.should == new_response
        end

      end
    end

    context "conditions governing caching" do
      describe "conditions where the response should not be cached" do
        it "should not store response in cache if the original request was not GET" do
          post = Wrest::Native::Post.new(@request_uri, {}, {}, cacheable_headers, {:cache_store => @cache})
          post.should_receive(:do_request).and_return(mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))

          @cache.should_not_receive(:has_key?)
          post.invoke
        end

        it "should not store response in cache if response is not cacheable" do
          response = Wrest::Native::Response.new(build_response('404', 'redirect', '', cacheable_headers))
          @get.should_receive(:invoke_without_cache_check).and_return(response)
          @cache.should_not_receive(:[]=).with(@request_uri, response)
          @get.invoke
        end
      end

      describe "conditions where the response should be cached" do
        it "should store response in cache if it did not exist in cache" do
          @cache.should_receive(:[]).with(@get.hash).and_return(nil)
          @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
          @cache.should_receive(:[]=).with(@get.hash, @ok_response)
          @get.invoke
        end

        it "should store response in cache if response is cacheable" do
          response = @ok_response
          response.cacheable?.should == true
          @get.should_receive(:invoke_without_cache_check).and_return(response)
          @cache.should_receive(:[]=).with(@get.hash, response)
          @get.invoke
        end
      end
    end
  end

  context "functional", :functional => true do
    before :each do
      @cache_store = {}
      @l = "http://localhost:3000".to_uri(:cache_store => @cache_store)
    end

    describe "cacheable responses" do
      it "should cache cacheable but cant_be_validated response" do
        response = @l["cacheable/cant_be_validated/with_expires/300"].get
        @cache_store.values.should include(response)

        response = @l["cacheable/cant_be_validated/with_max_age/300"].get
        @cache_store.values.should include(response)

        response = @l["cacheable/cant_be_validated/with_both_max_age_and_expires/300"].get
        @cache_store.values.should include(response)        
      end

      it "should not cache any non-cacheable response" do

        @l["non_cacheable/nothing_explicitly_defined"].get
        @l["non_cacheable/non_cacheable_statuscode"].get
        @l["non_cacheable/no_store"].get
        @l["non_cacheable/no_cache"].get
        @l["non_cacheable/with_etag"].get

        @cache_store.should be_empty

      end
    end
  end

end
