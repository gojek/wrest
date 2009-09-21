ENV['RAILS_ENV'] = RAILS_ENV = 'test'

require File.dirname(__FILE__) + '/../../spec_helper'

describe "Rails" do
  describe "testing" do
    it "should raise an exception if an actual request is made" do
      lambda{ 'http://localhost/foo'.to_uri.get }.should raise_error(Wrest::Exceptions::RealRequestMadeInTestEnvironmet)
      lambda{ 'http://localhost/foo'.to_uri.post }.should raise_error(Wrest::Exceptions::RealRequestMadeInTestEnvironmet)
      lambda{ 'http://localhost/foo'.to_uri.put }.should raise_error(Wrest::Exceptions::RealRequestMadeInTestEnvironmet)
      lambda{ 'http://localhost/foo'.to_uri.delete }.should raise_error(Wrest::Exceptions::RealRequestMadeInTestEnvironmet)
    end
  end
end
