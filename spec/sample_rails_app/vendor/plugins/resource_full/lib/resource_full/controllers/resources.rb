module ResourceFull
  module Controllers
    class ResourcesController < ResourceFull::Base
      responds_to :xml

      protected
        def find_all_resources
          ResourceFull::Base.all_resources
        end

        def find_resource
          ResourceFull::Base.controller_for(params[:id].pluralize)
        end
    end
  end
end