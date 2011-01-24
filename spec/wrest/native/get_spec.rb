require "spec_helper"
require 'rspec'

describe Wrest::Native::Get do
  before :each do
    @cache       = Hash.new
    @request_uri = 'http://localhost/foo'.to_uri

    @get         = Wrest::Native::Get.new(@request_uri, {}, {}, {:cache_store => @cache})

  end
  context "hashing and equality" do
    it "should be equal to itself" do
      @get.should == @get
    end

    it "should be equal to its clone" do
      @get.should == @get.clone
      @get.hash.should == @get.clone.hash
    end

    it "should be equal to a similar get but with different options" do
      @another_get_with_same_properties = Wrest::Native::Get.new(@request_uri, {}, {}, {:cache_store => @cache.clone}) # Use a different cache store, but it should not be considered when checking equality.

      @get.should == @another_get_with_same_properties
      @get.hash.should == @another_get_with_same_properties.hash
    end

    it "should not be equal to a get with different parameters even with same url" do
      @another_get_with_extra_parameter = Wrest::Native::Get.new(@request_uri, {:a_parameter => 10}, {}, {:cache_store => @cache})
      @get.should_not == @another_get_with_extra_parameter
      @get.hash.should_not == @another_get_with_extra_parameter.hash
    end
  end

  context "caching" do
    it "should initialize CacheLogic" do
      CacheLogic.should_receive(:new)
      @get = Wrest::Native::Get.new(@request_uri, {}, {}, {:cache_store => @cache})
    end

    it "should route all requests through cache logic" do
      @get = Wrest::Native::Get.new(@request_uri, {}, {}, {:cache_store => @cache})
      @get.cache_logic.should_receive(:get).with(@get, @cache)
      @get.invoke
    end

    it "should call invoke_without_cache_check to make a fresh request if cache logic gives nothing" do
      @cache_logic.stub!(:get, nil)
      @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
      @get.invoke
    end

    it "should cache the response after invoke makes a fresh request" do
      @cache_logic.stub!(:get, nil)
      @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
      @cache_logic.should_receive(:set).with(@get.hash, @ok_response)
      @get.invoke
    end


    # When already in cache:
    it "should not call invoke_without_cache_check if response exists in cache" do
      @cache_logic.should_receive(:get).and_return(@ok_response)
      @get.should_not_receive(:invoke_without_cache_check)
      @get.invoke
    end
  end

  context "functional", :functional => true do
    before :each do
      @cache_store = {}
      @l           = "http://localhost:3000".to_uri(:cache_store => @cache_store)
    end

    describe "cacheable responses" do

      it "should not cache any non-cacheable response" do
        @l["non_cacheable/nothing_explicitly_defined"].get
        @l["non_cacheable/non_cacheable_statuscode"].get
        @l["non_cacheable/no_store"].get
        @l["non_cacheable/no_cache"].get
        @l["non_cacheable/with_etag"].get

        @cache_store.should be_empty
      end

      it "should cache cacheable but cant_be_validated response" do
        # The server returns a different body for the same url on every call. So if the copy is cached by the client,
        # they should be equal.

        @l["cacheable/cant_be_validated/with_expires/300"].get.should == @l["cacheable/cant_be_validated/with_expires/300"].get
        @l["cacheable/cant_be_validated/with_max_age/300"].get.should == @l["cacheable/cant_be_validated/with_max_age/300"].get
        @l["cacheable/cant_be_validated/with_both_max_age_and_expires/300"].get.should == @l["cacheable/cant_be_validated/with_both_max_age_and_expires/300"].get

        @l["cacheable/cant_be_validated/with_both_max_age_and_expires/300"].get.should_not == @l["cacheable/cant_be_validated/with_max_age/300"].get
      end

      it "should give the cached response itself when it has not expired" do
        initial_response = @l["cacheable/cant_be_validated/with_expires/1"].get
        next_response    = @l["cacheable/cant_be_validated/with_expires/1"].get

        next_response.body.split.first.should == initial_response.body.split.first
      end

      it "should give a new response after it has expired (for a non-validatable cache entry)" do
        initial_response = @l["cacheable/cant_be_validated/with_expires/1"].get
        sleep 1
        next_response = @l["cacheable/cant_be_validated/with_expires/1"].get

        next_response.body.split.first.should_not == initial_response.body.split.first
      end

      context "validatable cache entry" do
        it "should give the cached response itself if server gives a 304 (not modified)" do
          first_response_with_last_modified = @l['/cacheable/can_be_validated/with_last_modified/always_304/1'].get
          first_response_with_etag          = @l['/cacheable/can_be_validated/with_etag/always_304/1'].get
          sleep 2
          second_response_with_last_modified = @l['/cacheable/can_be_validated/with_last_modified/always_304/1'].get
          second_response_with_etag          = @l['/cacheable/can_be_validated/with_etag/always_304/1'].get

          first_response_with_last_modified.body.split.first.should == second_response_with_last_modified.body.split.first
          first_response_with_etag.body.split.first.should == second_response_with_etag.body.split.first

        end

        it "should update the headers of an existing cache entry when the server sends a 304" do
          # RFC 2616
          # If a cache uses a received 304 response to update a cache entry, the cache MUST update the entry to reflect any new field values given in the response.

          uri                               = "http://localhost:3000/cacheable/can_be_validated/with_last_modified/always_304/1".to_uri(:cache_store => Wrest::Components::CacheStore::Memcached.new(nil, :namespace => "wrest#{rand 1000}"))

          first_response_with_last_modified = uri.get # Gets a 200 OK
          first_response_with_last_modified.headers["Header-that-was-in-the-first-response"].should == "42"
          first_response_with_last_modified["header-that-changes-everytime"].should == nil

          sleep 1

          second_response_with_last_modified = uri.get # Cache expired. Wrest would send an If-Not-Modified, server will send 304 (Not Modified) with a header-that-changes-everytime
          second_response_with_last_modified.body.should == first_response_with_last_modified.body
          second_response_with_last_modified["header-that-changes-everytime"].to_i.should > 0
          second_response_with_last_modified.headers["Header-that-was-in-the-first-response"].should == "42"

          a_new_get_request_to_same_resource = uri.get
          a_new_get_request_to_same_resource.body.should == first_response_with_last_modified.body
          a_new_get_request_to_same_resource["header-that-changes-everytime"].to_i.should > 0
          a_new_get_request_to_same_resource["header-that-changes-everytime"].should_not == second_response_with_last_modified["header-that-changes-everytime"]
          a_new_get_request_to_same_resource.headers["Header-that-was-in-the-first-response"].should == "42"
        end


        it "should give the new response if server sends a new one" do
          first_response_with_last_modified = @l['/cacheable/can_be_validated/with_last_modified/always_give_fresh_response/1'].get
          first_response_with_etag          = @l['/cacheable/can_be_validated/with_etag/always_give_fresh_response/1'].get
          sleep 1
          second_response_with_last_modified = @l['/cacheable/can_be_validated/with_last_modified/always_give_fresh_response/1'].get
          second_response_with_etag          = @l['/cacheable/can_be_validated/with_etag/always_give_fresh_response/1'].get

          first_response_with_last_modified.body.split.first.should_not == second_response_with_last_modified.body.split.first
          first_response_with_etag.body.split.first.should_not == second_response_with_etag.body.split.first
        end

      end
    end
  end
end
