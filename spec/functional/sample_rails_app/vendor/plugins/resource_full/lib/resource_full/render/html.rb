module ResourceFull
  module Render
    module HTML
      protected
  
      def show_html
        self.model_object = send("find_#{model_name}")
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
      end

      def index_html
        self.model_objects = send("find_all_#{model_name.pluralize}")
      end

      def create_html
        self.model_object = send("create_#{model_name}")
        if model_object.errors.empty?
          flash[:info] = "Successfully created #{model_name.humanize} with ID of #{model_object.id}."
          redirect_to :action => :index, :format => :html
        else
          render :action => "new"
        end
      end

      def update_html
        self.model_object = send("update_#{model_name}")      
        if model_object.errors.empty?
          flash[:info] = "Successfully updated #{model_name.humanize} with ID of #{model_object.id}."
          redirect_to :action => :index, :format => :html
        else
          render :action => "edit"
        end
      end

      def destroy_html
        self.model_object = send("destroy_#{model_name}")
        flash[:info] = "Successfully destroyed #{model_name.humanize} with ID of #{params[:id]}."
        redirect_to :action => :index, :format => :html
      rescue ActiveRecord::RecordNotFound => e
        flash[:error] = e.message
        redirect_to :back
      end
  
      def new_html
        self.model_object = send("new_#{model_name}")
      end
    end
  end
end