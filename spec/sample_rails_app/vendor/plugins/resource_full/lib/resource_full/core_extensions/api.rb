module ResourceFull
  module CoreExtensions
    module API
      
      # Generate ActionController routes for RESTful services documentation.
      def api
        with_options :format => 'xml', :conditions => { :method => :get } do |map|
          map.named_route 'resource',         '/resources/:id.xml', 
            :action => 'show',  :controller => 'resource_full/controllers/resources'
          map.named_route 'resources',        '/resources.xml', 
            :action => 'index', :controller => 'resource_full/controllers/resources'
          map.named_route 'resources_route',  '/resources/:resource_id/routes/:id.xml', 
            :action => 'show',  :controller => 'resource_full/controllers/routes'
          map.named_route 'resources_routes', '/resources/:resource_id/routes.xml', 
            :action => 'index', :controller => 'resource_full/controllers/routes'
          map.named_route 'routes', '/routes.xml',
            :action => 'index', :controller => 'resource_full/controllers/routes'
        end
      end
    end
  end
end

class ActionController::Routing::RouteSet::Mapper
  include ResourceFull::CoreExtensions::API
end
