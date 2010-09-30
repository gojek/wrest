require "spec_helper"

module Wrest::Components::Translators
  describe Json do
    it "should know how to convert json to a hashmap" do
      http_response = mock('Http Reponse')
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

    Json.deserialise(http_response).should == { "commands"=>[{"title"=>"New", "action"=>"CreateDoc"},
        {"title"=>"Open","action"=>"OpenDoc"},{"title"=>"Close", "action"=>"CloseDoc"}],
        "menu"=>"File"}

    end
  end
end
