# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")
require 'digest/md5'

Wrest.logger = Logger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG  # Set this to Logger::INFO or higher to disable request logging
# Wrest.use_curl

include Wrest

# This example demonstrates fetching a Facebook user's public profile
# given his or her Facebook UID. It also shows how strings in the 
# deserialised response can be easily converted into other objects 
# using Wrest's typecast feature.

module Facebook
  # This key and secret are both fake. To get your own key and secret, create a
  # Facebook application at http://www.facebook.com/developers/apps.php
  Config ={
    :key => '8be7dc2e480d8bf21a58915bad8c362e',
    :secret => '1a4638b19c393b540fda796f936a25d4',
    :restserver => 'http://api.facebook.com/restserver.php'
  }
    
  module API
    Defaults = {
      'v' => '1.0',
      'format' => 'XML',
      'api_key' => Config[:key]
    }
    
    def self.signature_for(params)
      # http://wiki.developers.facebook.com/index.php/How_Facebook_Authenticates_Your_Application
      request_str = params.keys.sort.map{|k| "#{k}=#{params[k]}" }.join
      Digest::MD5.hexdigest(request_str + Config[:secret])
    end
    
    def self.invoke(args)
      args = API::Defaults.merge(args)
      Config[:restserver].to_uri.post_form(args.merge('sig' => Facebook::API.signature_for(args))).deserialise
    end
  end
  
  class Profile
    include Components::Container
    typecast  :uid        => as_integer,
              :pic_square => lambda{|pic_square| pic_square.to_uri}

    Fields = %w(
      uid
      first_name
      last_name
      name
      pic_square
    ).join(', ')
    
    def self.find(fcbk_uid)
      hash = Facebook::API.invoke({
        'method' => 'facebook.users.getInfo', 
        'fields' => Profile::Fields,
        'uids' => fcbk_uid
      })
      
      if hash['error_response']
        Facebook::Error.new hash['error_response']
      else
        self.new hash["users_getInfo_response"]["user"]
      end
    end
  end
  
  class Error
    include Components::Container
    typecast :error_code => as_integer
  end
end

puts 'Fetching public profile for Facebook user 699497090.' 
puts 'Note that we use Wrest\'s typecast feature to convert the uid and pic_square fields in the case of a valid result, and the error_msg and error_code fields in the case of an Error to appropriate types from simple strings.'
puts

profile = Facebook::Profile.find('699497090')

puts "Field\t\t\tData\t\t\tClass"

if profile.is_a? Facebook::Error
  puts "Error\t\t\t#{profile.error_msg}\t\t\t#{profile.error_msg.class}"
  puts "Code\t\t\t#{profile.error_code}\t\t\t#{profile.error_code.class}"
else
  puts "UID\t\t\t#{profile.uid}\t\t\t#{profile.uid.class}"
  puts "Name\t\t\t#{profile.first_name}\t\t\t#{profile.first_name.class}"
  puts "Pic Url\t\t\t#{profile.pic_square}\t\t\t#{profile.pic_square.class}"
end  