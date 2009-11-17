ActionController::Routing::Routes.draw do |map|
  map.headers '/headers', :controller => 'application', :action => 'headers'
  
  map.resources :glass_bottles, :lead_bottles
end
