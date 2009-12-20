require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest
  describe Native::Request do
    it "should fetch a response from the cache should a request return a 304" # do
     #      etag = 'http://github.com/api/v1/xml/kaiwren'.to_uri.get['etag'].gsub('""', '')
     #      'http://github.com/api/v1/xml/kaiwren'.to_uri.get({}, H::IfNoneMatch => etag).code.should == '304'
     #    end
  end
end