# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  class UriTemplate
    attr_reader :uri_pattern
    def initialize(uri_pattern)
      @uri_pattern = uri_pattern.clone
    end
    
    # Builds a new Wrest::Uri from this uri template 
    # by replacing the keys in the options that match with
    # the corressponding values.
    #
    # Example:
    # template = UriTemplate.new("http://coathangers.com/:resource/:id.:format")
    # template.to_uri(:resource => 'shen_coins', :id => 5, :format => :json)
    # => #<Wrest::Uri:0x1225514 @uri=#<URI::HTTP:0x9127d8 URL:http://localhost:3000/shen_coins/5.json>>
    #
    # This feature can also be used to handle HTTP authentication where the username
    # and password needs changing at runtime. However, this approach _will_ fail if
    # the password contains characters like ^ and @.
    #
    # Note that beacuse because both HTTP Auth and UriTemplate
    # use ':' as a delimiter, the pattern does look slightly weird, but it still works.
    #
    # Example:
    # template = UriTemplate.new("http://:username::password@coathangers.com/:resource/:id.:format")
    # template.to_uri(
    #  :user => 'kaiwren',
    #  :password => 'fupuppies',
    #  :resource => 'portal',
    #  :id => '1'
    # )
    #  => #<Wrest::Uri:0x18e0bec @uri=#<URI::HTTP:0x18e09a8 URL:http://kaiwren:fupuppies@coathangers.com/portal/1>>
    def to_uri(options = {})
      options.inject(uri_pattern.clone) do |uri_string, tuple| 
        key, value = tuple
        uri_string.gsub(":#{key.to_s}", value.to_s)
      end.to_uri
    end
  end
end
