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

      it "should call get_cached_response before making actual request" do
        @get.should_receive(:get_cached_response)
        @get.invoke
      end

      it "should call cache_response after calling invoke method for fresh request" do
        @get.should_receive(:get_cached_response).and_return(nil)
        @get.should_receive(:cache_response)
        @get.invoke
      end

      it "should check if response already exists cache before making a request" do
        @cache.should_receive(:has_key?).with(@get.hash)
        @get.invoke
      end
    end

    it "should call invoke_without_cache_check if response does not exist in cache" do
      @cache.should_receive(:has_key?).with(@get.hash).and_return(false)
      @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
      @get.invoke
    end

    it "should not call invoke_without_cache_check if response exists in cache" do
      @cache.should_receive(:has_key?).with(@get.hash).and_return(true)
      @cache.should_receive(:fetch).with(@get.hash).and_return(@ok_response)
      @get.should_not_receive(:invoke_without_cache_check)
      @get.invoke
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
        response = @ok_response
        @cache.should_receive(:has_key?).with(@get.hash).and_return(false)
        @get.should_receive(:invoke_without_cache_check).and_return(response)
        @cache.should_receive(:[]=).with(@get.hash, response)
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
