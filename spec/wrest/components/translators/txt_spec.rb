require "spec_helper"

module Wrest::Components::Translators
  describe Txt do
    let(:http_response) { mock('Http Reponse') }
    it "should return response body when deserialise" do
      http_response.should_receive(:body).and_return("Homebrew is the easiest.")

      Txt.deserialise(http_response).should == "Homebrew is the easiest."
    end

    it "should return string version of any object when serialise" do
      Txt.serialise({"ooga"=>{"age" => "12"}}).should == "{\"ooga\"=>{\"age\"=>\"12\"}}"
    end
    
    it "has #deserialize delegate to #deserialise" do
      Txt.should_receive(:deserialise).with(http_response, :option => :something)
      Txt.deserialize(http_response, :option => :something)
    end
    
    it "has #serialize delegate to #serialise" do
      Txt.should_receive(:serialise).with({ :hash => :foo }, :option => :something)
      Txt.serialize({:hash => :foo}, :option => :something)
    end
  end
end
