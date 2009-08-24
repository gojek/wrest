if ([Rails::VERSION::MAJOR, Rails::VERSION::MINOR] <=> [2,1]) >= 0 # if the rails version is 2.1 or greater...Í
  ActiveRecord::Base.include_root_in_json = true
end

require 'resource_full'
