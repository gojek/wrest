module ResourceFull
  module Render
    module XML
      protected

      def show_xml_options
        {}
      end
      def show_xml
        self.model_object = send("find_#{model_name}")
        render :xml => model_object.to_xml(show_xml_options)
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end

      def index_xml_options
        {}
      end
      def index_xml
        self.model_objects = send("find_all_#{model_name.pluralize}")
        render :xml => model_objects.to_xml(index_xml_options)
      end

      def create_xml_options
        {}
      end
      def create_xml
        self.model_object = send("create_#{model_name}")
        if model_object.errors.empty?
          render :xml => model_object.to_xml(create_xml_options), :status => :created, :location => send("#{model_name}_url", model_object.id)
        else
          render :xml => model_object.errors.to_xml, :status => status_for(model_object.errors)
        end
      end

      def update_xml_options
        {}
      end
      def update_xml
        self.model_object = send("update_#{model_name}")
        if model_object.errors.empty?
          render :xml => model_object.to_xml(update_xml_options)
        else
          render :xml => model_object.errors.to_xml, :status => status_for(model_object.errors)
        end
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end

      def destroy_xml
        self.model_object = send("destroy_#{model_name}")
        head :ok
      rescue ActiveRecord::RecordNotFound => e
        render :xml => e.to_xml, :status => :not_found
      end

      def new_xml_options
        {}
      end
      def new_xml
        render :xml => send("new_#{model_name}").to_xml(new_xml_options)
      end
    end
  end
end
