# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../lib/wrest')

class Representative
  BASE_URI = 'http://whoismyrepresentative.com/'

  def self.find_by_zipcode(zipcode)
    uri = (BASE_URI + 'getall_mems.php?').to_uri
    uri.get(zip: zipcode).deserialize
  end

  def self.find_by_name(lastname)
    uri = (BASE_URI + 'getall_reps_byname.php').to_uri
    uri.get(name: lastname).deserialize
  end

  def self.find_by_state(state)
    uri = (BASE_URI + 'getall_reps_bystate.php?').to_uri
    uri.get(state: state).deserialize
  end
end

puts Representative.find_by_zipcode(31_023)
puts Representative.find_by_name('smith')
puts Representative.find_by_state('FL')
