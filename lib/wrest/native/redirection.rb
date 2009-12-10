# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at Http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest #:nodoc:
  module Native #:nodoc:
    # Constructed by Wrest::Response.new if the HTTP response code is 3xx 
    # (http://en.wikipedia.org/wiki/300_Multiple_Choices#3xx_Redirection)
    # 
    # This class is necessary because Net::HTTP doesn't seem to support
    # redirection natively.
    class Redirection < Response
      
      # A get is invoked on the url stored in the response headers
      # under the key 'location' and the new Response is returned.
      #
      # The follow_redirects_count and follow_redirects_limit options 
      # should be present. follow_redirects_count will be incremented by 1.
      #
      # This method will raise a Wrest::Exceptions::AutoRedirectLimitExceeded
      # if the follow_redirects_count equals the follow_redirects_limit.
      def follow(redirect_request_options = {})
        target = self['location']
        redirect_request_options = redirect_request_options.clone

        raise Wrest::Exceptions::AutoRedirectLimitExceeded if (redirect_request_options[:follow_redirects_count] += 1) >= redirect_request_options[:follow_redirects_limit]

        Wrest.logger.debug "--| Redirecting to #{target}"
        target.to_uri(redirect_request_options).get
      end
    end
  end
end