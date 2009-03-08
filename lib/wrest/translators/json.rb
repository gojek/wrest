require 'json'

module Wrest
  module Translators
    Json = lambda{|response| 
        JSON.parse(response.body)
    }
  end
end
    