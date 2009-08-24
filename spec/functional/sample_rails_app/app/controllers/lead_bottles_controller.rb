class LeadBottlesController < ResourceFull::Base
  queryable_with :name, :fuzzy => true
  

  responds_to :xml
  responds_to :json
end