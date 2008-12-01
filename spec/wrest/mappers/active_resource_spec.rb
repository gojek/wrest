require File.dirname(__FILE__) + '/../../spec_helper'

module Wrest::Mappers
  describe ActiveResource  do
    before :all do
      @example_klass = Class.new(ActiveResource)
      @example_klass.class_eval do
        translator    Wrest::Translators::Xml
        resource_host 'http://localhost:3000' 
      end
    end
    
    it "should initialize its translator class" do
      @example_klass.new('ooga' => 'booga').translator_klass.should == Wrest::Translators::Xml
    end
  end
end
