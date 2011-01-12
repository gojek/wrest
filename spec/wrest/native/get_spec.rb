require "spec_helper"
require 'rspec'

describe Wrest::Native::Get do

  before :each do
    @cache = Hash.new
    @request_uri = 'http://localhost/foo'.to_uri

    @get = Wrest::Native::Get.new(@request_uri, {},{},{:cache_store => @cache})
    @another_get_with_same_properties = Wrest::Native::Get.new(@request_uri, {},{},{:cache_store => @cache.clone})  # Use a different cache store, but it should not be considered when checking equality.
    @another_get_with_extra_parameter = Wrest::Native::Get.new(@request_uri,  {:a_parameter => 10},{},{:cache_store => @cache})
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
      ten_mins_early = (Time.now - (10*30)).httpdate

      # All responses in the caching block returns a cacheable response by default
      headers = { "Date" => Time.now.httpdate, "Expires" => half_hour_after, "Age" => 0, "Last-Modified" => ten_mins_early}

    end
  end
  
  describe "caching" do

    before :each do
      @ok_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers()))
    end

    describe "dependencies" do
      before :each do
        @get.stub!(:invoke_without_cache_check).and_return(@ok_response)
      end

      it "should cache the response after invoke makes a fresh request" do
        @cache.should_receive(:[]).and_return(nil)
        @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
        @cache.should_receive(:[]=).with(@get.hash, @ok_response)
        @get.invoke
      end

      it "should check if response already exists in cache before making a request" do
        @cache.should_receive(:[]).with(@get.hash)
        @get.invoke
      end

      it "should check whether the cache entry has expired" do
        @cache.should_receive(:[]).and_return(@ok_response)
        @ok_response.should_receive(:expired?)
        @get.invoke
      end

    end

    it "should call invoke_without_cache_check if response does not exist in cache" do
      @cache.should_receive(:[]).with(@get.hash).and_return(nil)
      @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
      @get.invoke
    end

    it "should not call invoke_without_cache_check if response exists in cache" do
      @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)
      @get.should_not_receive(:invoke_without_cache_check)
      @get.invoke
    end

    it "should check if an expired cache entry whether it can be validated" do
      @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

      @ok_response.should_receive(:expired?).and_return(true)
      @ok_response.should_receive(:can_be_validated?).and_return(false)

      @get.should_receive(:invoke_without_cache_check).and_return(nil)

      @get.invoke
    end

    describe "when a cache entry can be validated by sending an If-Modified-Since or If-None-Match" do

      it "should say a cache entry with Last-Modified can be validated" do
        @ok_response.should_receive(:expired?).and_return(true)
        @ok_response.can_be_validated?.should == true # by default @ok_response has cacheable_headers that has a Last-Modified.

        @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

        @get.should_receive(:get_new_response_after_cache_validation).and_return(@ok_response)

        @get.invoke
      end

      it "should say a cache entry with ETag can be validated" do

        @ok_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers().tap { |h| h.delete "Last-Modified"; h["ETag"]='123' }))
        @ok_response.should_receive(:expired?).and_return(true)
        @ok_response.can_be_validated?.should == true

        @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

        @get.should_receive(:get_new_response_after_cache_validation).and_return(@ok_response)
        
        @get.invoke
      end

      it "should say a cache entry with neither Last-Modified nor ETag cannot be validated" do
        @ok_response = Wrest::Native::Response.new(build_ok_response('', cacheable_headers().tap { |h| h.delete "Last-Modified" }))
        @ok_response.should_receive(:expired?).and_return(true)
        @ok_response.can_be_validated?.should == false

        @cache.should_receive(:[]).with(@get.hash).and_return(@ok_response)

        @get.should_receive(:invoke_without_cache_check).and_return(nil)
        @get.invoke
      end
    end

    describe "conditions where the response should not be cached" do
      it "should not store response in cache if the original request was not GET" do
        post = Wrest::Native::Post.new(@request_uri, {}, {}, cacheable_headers, {:cache_store => @cache})
        post.should_receive(:do_request).and_return(mock(Net::HTTPOK, :code => "200", :message => 'OK', :body => '', :to_hash => {}))

        @cache.should_not_receive(:has_key?)
        post.invoke
      end

      it "should not store response in cache if response is not cacheable" do
        response = Wrest::Native::Response.new(build_response('404','redirect', '', cacheable_headers))
        @get.should_receive(:invoke_without_cache_check).and_return(response)
        @cache.should_not_receive(:[]=).with(@request_uri,response)
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
        @get.should_receive(:invoke_without_cache_check).and_return(response)
        @cache.should_receive(:[]=).with(@get.hash, response)
        @get.invoke
      end
    end
  end

end
