require "spec_helper"

describe Wrest::Native::Get do

  before :each do
    @request_uri = 'http://localhost/foo'.to_uri
    @cache = Hash.new
    @ok_response = Wrest::Native::Response.new(build_ok_response)

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
    end
  end
  
  describe "caching" do

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

    it "should store response in cache if it did not exist in cache" do
      response = @ok_response
      @cache.should_receive(:has_key?).with(@get.hash).and_return(false)
      @get.should_receive(:invoke_without_cache_check).and_return(response)
      @cache.should_receive(:[]=).with(@get.hash,response)
      @get.invoke
    end

    it "should store response in cache if response is cacheable" do
      response = @ok_response
      @get.should_receive(:invoke_without_cache_check).and_return(response)
      @cache.should_receive(:[]=).with(@get.hash,response)
      @get.invoke
    end

    it "should not store response in cache if response is not cacheable" do
      response = Wrest::Native::Response.new(build_response('404','redirect'))
      @get.should_receive(:invoke_without_cache_check).and_return(response)
      @cache.should_not_receive(:[]=).with(@request_uri,response)
      @get.invoke
    end
  end
end
