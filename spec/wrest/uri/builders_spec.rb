require 'spec_helper'

describe Wrest::Uri::Builders do
  let(:uri) { "http://localhost:3000".to_uri }
  context "using_threads" do
    it "should return a new uri" do
      threaded_uri = uri.using_threads
      uri.should_not equal(threaded_uri)
    end

    it "should have the thread backend in options hash" do
      uri = "http://localhost:3000/no_body".to_uri
      threaded_uri = uri.using_threads
      threaded_uri.instance_variable_get("@options")[:asynchronous_backend].should be_an_instance_of(Wrest::AsyncRequest::ThreadBackend)
    end
  end

  context "using_em" do
    before(:all){ Wrest::AsyncRequest.enable_em }
    it "should return a new uri" do
      evented_uri = uri.using_em
      uri.should_not equal(evented_uri)
    end

    it "should have the eventmachine backend in options hash" do
      evented_uri = uri.using_em
      evented_uri.instance_variable_get("@options")[:asynchronous_backend].should be_a(Wrest::AsyncRequest::EventMachineBackend)
    end
  end

  context "using_hash" do
    it "should return a new uri" do
      cache_enabled_uri = uri.using_hash
      uri.should_not equal(cache_enabled_uri)
    end

    it "should set a hash as cache store in options hash" do
      cache_enabled_uri = uri.using_hash
      cache_enabled_uri.instance_variable_get("@options")[:cache_store].should be_an_instance_of(Hash)
    end
  end

  context "using_memcached" do
    before(:all){ Wrest::Caching.enable_memcached }
    it "should return a new uri" do
      cache_enabled_uri = uri.using_memcached
      uri.should_not equal(cache_enabled_uri)
    end

    it "should set memcached as cache store in options hash" do
      cache_enabled_uri = uri.using_memcached
      cache_enabled_uri.instance_variable_get("@options")[:cache_store].should be_an_instance_of(Wrest::Caching::Memcached)
    end
  end

  context "disable_cache" do
    it "should return a new uri" do
      cache_disabled_uri = uri.disable_cache
      uri.should_not equal(cache_disabled_uri)
    end

    it "should set a flag indicating to disable cache on requests made through the uri" do
      cache_disabled_uri = uri.disable_cache
      cache_disabled_uri.instance_variable_get("@options")[:disable_cache].should be_truthy
    end
  end

  context "using_cookie" do
    it "builds a new Uri that has the cookie as a default" do
      cookied_uri = uri.using_cookie('some-encoded-cookie-string')
      cookied_uri.default_headers.should eq(Wrest::H::Cookie => 'some-encoded-cookie-string')
    end
  end
end
