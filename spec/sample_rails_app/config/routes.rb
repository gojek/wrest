ActionController::Routing::Routes.draw do |map|
  map.headers '/headers', :controller => 'application', :action => 'headers'
  map.headers '/no_body', :controller => 'application', :action => 'no_body'
  map.headers '/nothing', :controller => 'application', :action => 'nothing'
  map.headers '/no_bodies/:id.:format', :controller => 'application', :action => 'no_body'
  map.headers '/no_bodies.:format', :controller => 'application', :action => 'no_body'
  
  map.headers '/one_second', :controller => 'application', :action => 'one_second'
  map.headers '/two_seconds', :controller => 'application', :action => 'two_seconds'
  map.headers '/eight_seconds', :controller => 'application', :action => 'eight_seconds'
  
  map.resources :glass_bottles, :lead_bottles
  map.resources :uploads, :only => [:create, :update]
end
