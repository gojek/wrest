require 'json'

module Wrest
  module Translators
    # Knows how to deserialise json. 
    # Depends on the json gem.
    Json = lambda{|response| 
        JSON.parse(response.body)
    }
  end
end
    