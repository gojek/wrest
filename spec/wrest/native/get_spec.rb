# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.dirname(__FILE__) + '/../../spec_helper'

describe Wrest::Native::Get do
  describe "caching" do
  
    before :each do
      @request_uri = 'http://localhost/foo'.to_uri
      @cache = Hash.new
      @get = Wrest::Native::Get.new(@request_uri, {},{},{:cache_store => @cache})
      @ok_response = Wrest::Native::Response.new(build_ok_response)
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
        @cache.should_receive(:has_key?).with(@request_uri)
        @get.invoke
      end
    end

    it "should call invoke_without_cache_check if response does not exist in cache" do
      @cache.should_receive(:has_key?).with(@request_uri).and_return(false)
      @get.should_receive(:invoke_without_cache_check).and_return(@ok_response)
      @get.invoke
    end

    it "should not call invoke_without_cache_check if response exists in cache" do
      @cache.should_receive(:has_key?).with(@request_uri).and_return(true)
      @cache.should_receive(:fetch).with(@request_uri).and_return(@ok_response)
      @get.should_not_receive(:invoke_without_cache_check)
      @get.invoke
    end

    it "should store response in cache if it did not exist in cache" do
      response = @ok_response
      @cache.should_receive(:has_key?).with(@request_uri).and_return(false)
      @get.should_receive(:invoke_without_cache_check).and_return(response)
      @cache.should_receive(:[]=).with(@request_uri,response)
      @get.invoke
    end

    it "should store response in cache if response is cacheable" do
      response = @ok_response
      @get.should_receive(:invoke_without_cache_check).and_return(response)
      @cache.should_receive(:[]=).with(@request_uri,response)
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
