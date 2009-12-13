# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")

Wrest.logger = Logger.new(STDOUT)
Wrest.logger.level = Logger::DEBUG  # Set this to Logger::INFO or higher to disable request logging

# Optionally uncomment the following line to use the significantly faster libcurl library.
# This uses the patron gem - (sudo) gem install patron
# IMPORTANT: Libcurl support is currently in alpha and is both incomplete and unstable!
# Wrest.use_curl


include Wrest

class Realm
  include Components::Container

  typecast  :t => lambda{|type| 
                    case type
                      when '1' then 'Normal'
                      when '2' then 'PvP'
                      when '3' then 'RP'
                      when '4' then 'RP PvP'
                    end    
                  },
            :s => lambda{|status| 
                    case status
                      when '1' then 'Available'
                      else 'Unavailable'
                    end  
                  },
            :l => lambda{|load|
                    case load
                      when '1' then 'Low'
                      when '2' then 'Normal'
                      when '3' then 'High'
                      when '4' then 'Max'
                    end  
                  }
                  
  alias_accessors :t => :type, 
                  :s => :status,
                  :l => :load,
                  :n => :name
  
  def available?
    self.s == 'Available'
  end                
end

realms = "http://www.worldofwarcraft.com/realmstatus/status.xml".to_uri.get.deserialise['page']['rs']['r'].collect{|data| Realm.new(data)}

puts "Status of Nagrand: #{realms.find{|realm| realm.name == 'Nagrand'}.status}"
puts
puts "Listing All Available Realms:"
puts
puts "Realm\tLoad\tType"
puts "-----------"
realms.select(&:available?).each{|realm| puts "#{realm.name}\t#{realm.load}\t#{realm.type}" }