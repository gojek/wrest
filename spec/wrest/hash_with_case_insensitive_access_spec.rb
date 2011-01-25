require "spec_helper"

module Wrest

  describe HashWithCaseInsensitiveAccess do
    before(:each) do
      @hash = Wrest::HashWithCaseInsensitiveAccess.new "FOO" => 'bar', 'baz' => 'bee', 22 => 2002, :xyz => "pqr"
    end

    it "has values accessible irrespective of case" do
      @hash['foo'].should == 'bar'
      @hash["Foo"].should == 'bar'

      @hash.values_at("foo", "bAZ").should == ['bar', 'bee']
      @hash.delete("FOO").should == 'bar'
    end

    it "merges keys independent irrespective of case" do
      @hash.merge!('force' => false, "bAz" => "boom")
      @hash["force"].should == false
      @hash["baz"].should == "boom"
    end

    it "creates a new hash by merging keys irrespective of case" do
      other = @hash.merge('force' => false, :baz => "boom")
      other['force'].should == false
      other['FORCE'].should == false
      other[:baz].should == "boom"
    end

    it "works normally for non-string keys" do
      @hash[22].should == 2002
      @hash[:xyz].should == "pqr"
    end
  end

end