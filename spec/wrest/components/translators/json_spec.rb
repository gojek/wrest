require "spec_helper"

module Wrest::Components::Translators
  describe Json do
    let(:http_response) { mock('Http Reponse') }
    
    it "should know how to convert json to a hashmap" do
      http_response.should_receive(:body).and_return("{ 
      \"menu\": \"File\", 
      \"commands\": [ 
      {
          \"title\": \"New\", 
          \"action\":\"CreateDoc\"
      }, 
      {
          \"title\": \"Open\", 
          \"action\": \"OpenDoc\"
      }, 
      {
          \"title\": \"Close\",
          \"action\": \"CloseDoc\"
      }
      ] 
      }")

      result = { "commands"=>[{"title"=>"New", "action"=>"CreateDoc"},
        {"title"=>"Open","action"=>"OpenDoc"},{"title"=>"Close", "action"=>"CloseDoc"}],
        "menu"=>"File"}
      Json.deserialise(http_response).should eq(result)
    end
    
    it "should know how to convert json to a hashmap" do
      json = "{\"menu\":\"File\",\"commands\":[{\"title\":\"New\",\"action\":\"CreateDoc\"},{\"title\":\"Open\",\"action\":\"OpenDoc\"},{\"title\":\"Close\",\"action\":\"CloseDoc\"}]}"
      hash = {
        "menu"=>"File",
        "commands"=>[{
          "title"=>"New", 
          "action"=>"CreateDoc"},
          {
            "title"=>"Open",
            "action"=>"OpenDoc"},
            {"title"=>"Close", "action"=>"CloseDoc"}
      ]}
      Json.serialise(hash).should eq(json)
    end
    
    it "has #deserialize delegate to #deserialise" do
      Json.should_receive(:deserialise).with(http_response, :option => :something)
      Json.deserialize(http_response, :option => :something)
    end
    
    it "has #serialize delegate to #serialise" do
      Json.should_receive(:serialise).with({ :hash => :foo }, :option => :something)
      Json.serialize({:hash => :foo}, :option => :something)
    end
  end
end
