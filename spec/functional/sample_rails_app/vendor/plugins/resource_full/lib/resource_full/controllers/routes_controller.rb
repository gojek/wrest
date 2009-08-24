module ResourceFull
  module Controllers
    class RoutesController < ResourceFull::Base
      exposes ResourceFull::Models::ResourcedRoute
      responds_to :xml, :only => [ :read ]
      
      def index_xml
        render :xml => find_all_routes.to_xml(:root => "routes")
      end
      
      def find_all_routes
        ResourceFull::Models::ResourcedRoute.find :all, params
      end
    end
  end
end