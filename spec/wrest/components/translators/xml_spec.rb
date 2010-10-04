require "spec_helper"

module Wrest::Components::Translators
  describe Xml do
    it "should know how to convert xml to a hashmap" do
      http_response = mock('Http Reponse')
      http_response.should_receive(:body).and_return("<ooga><age>12</age></ooga>")

      Xml.deserialise(http_response).should == {"ooga"=>{"age"=> "12"}}
    end

    it "should know how to convert a hashmap to xml" do
      Xml.serialise({"ooga"=>{"age" => "12"}}).should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <ooga>\n    <age>12</age>\n  </ooga>\n</hash>\n"
    end
    
    it "should call filter only if xpath is specified" do
      
      http_response = mock('Http Response')
      http_response.should_receive(:body)
      ActiveSupport::XmlMini.should_receive(:filter)
      Xml.deserialise(http_response,{:xpath=>'//age'})
    end

    
    it "should not call filter if xpath is not specified" do
      
      http_response = mock('Http Response')
      http_response.should_receive(:body).and_return("<Person><Personal><Name><FirstName>Nikhil</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>")
      Xml.should_not_receive(:filter)

      Xml.deserialise(http_response)
    end
    
    backend = ['Nokogiri','REXML']
    backend.each { |e| 
      it "should be able to pull out desired elements from an xml response based on xpath and return an array of matching nodes" do
        ActiveSupport::XmlMini.backend = e
        p ActiveSupport::XmlMini.backend
        
        http_response = mock('Http Response')
        http_response.should_receive(:body).and_return("<Person><Personal><Name><FirstName>Nikhil</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>")
        
        res_arr = Xml.deserialise(http_response,{:xpath=>'//Name'})
        result = ""
        res_arr.each { |a| result+= a.to_s.gsub(/[\n]+/, "").gsub(/\s/, '')}
        result.should == "<Name><FirstName>Nikhil</FirstName></Name><Name>Bangalore</Name>" 
      end
    }
    end
end
