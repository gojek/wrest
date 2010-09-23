module ActiveSupport
  module XmlMini_REXML 
    #enables filtering an xml response using a specified xpath
    #it returns the first element that matches the xpath
    def filter(http_response,xpath)
      doc = REXML::Document.new(http_response.body)
      REXML::XPath.first(doc,xpath).to_s
    end
  end
end

    
