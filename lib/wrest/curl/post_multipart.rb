# Copyright 2009 - 2010 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Curl
  class PostMultipart < Request
    def initialize(wrest_uri, parameters = {}, headers = {}, options = {})
      parameters = parameters.inject({}) {|parameters_sym, (k,v)| parameters_sym[k.to_sym] = v; parameters_sym}
      options.merge!(:data => parameters[:data])
      options.merge!(:file => parameters[:file])
      options.merge!({:multipart => true})
      parameters.delete(:data)
      parameters.delete(:file)
      super(
        wrest_uri,
        :post,
        parameters,
        options[:data],
        headers,
        options
      )
    end
  end
end
