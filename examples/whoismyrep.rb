require File.expand_path(File.dirname(__FILE__) + "/../lib/wrest")

class Representative
  @@base_uri =  'http://whoismyrepresentative.com/'

  def self.find_by_zipcode(zipcode)
    uri = (@@base_uri + 'getall_mems.php?').to_uri
    uri.get(zip: zipcode).deserialize
  end

  def self.find_by_name(lastname)
    uri = (@@base_uri + 'getall_reps_byname.php').to_uri
    uri.get(name: lastname).deserialize
  end

  def self.find_by_state(state)
    uri = (@@base_uri + 'getall_reps_bystate.php?').to_uri
    uri.get(state: state).deserialize
  end

end

puts Representative.find_by_zipcode(31023)
puts Representative.find_by_name('smith')
puts Representative.find_by_state('FL')