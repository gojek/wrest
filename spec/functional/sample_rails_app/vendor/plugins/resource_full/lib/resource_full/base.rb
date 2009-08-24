module ResourceFull
  class ResourceNotFound < Exception; end
  
  class Base < ActionController::Base
    unless Rails.version == "2.3.2"
      session :off, :if => lambda { |request| request.format.xml? || request.format.json? }
    end

    def model_name; self.class.model_name; end
    def model_class; self.class.model_class; end

    class << self
      # Returns the list of all resources handled by ResourceFull.
      def all_resources
        ActionController::Routing.possible_controllers.map do |possible_controller|
          controller_for(possible_controller)
        end.select do |controller_class|
          controller_class.ancestors.include?(self)
        end
      end
      
      # Returns the controller for the given resource.
      def controller_for(resource)
        return resource if resource.is_a?(Class) && resource.ancestors.include?(ActionController::Base)
        "#{resource.to_s.underscore}_controller".classify.constantize
      rescue NameError
        raise ResourceFull::ResourceNotFound, "not found: #{resource}"
      end
      
      private
      
        def inherited(controller)
          super(controller)
          controller.send :extend, ClassMethods
          controller.send :include, 
            ResourceFull::Retrieve, 
            ResourceFull::Query, 
            ResourceFull::Dispatch, 
            ResourceFull::Render
          controller.send :alias_retrieval_methods!
        end
    end
  end

  module ClassMethods
    attr_accessor_with_default :paginatable, true
    attr_accessor_with_default :resource_identifier, :id
    
    # Returns true if this resource is paginatable, which is to say, it recognizes and honors
    # the :limit and :offset parameters if present in a query.  True by default.
    def paginatable?; paginatable; end
    
    # The name of the model exposed by this resource.  Derived from the name of the controller
    # by default.  See +exposes+.
    def model_name
      @model_class ? @model_class.to_s.underscore : self.controller_name.singularize
    end
    
    # Indicates that this resource is identified by a database column other than the default
    # :id.  
    # TODO This should honor the model's primary key column but needn't be bound by it.
    # TODO Refactor this.
    # TODO Improve the documentation.
    def identified_by(*args, &block)
      opts = args.extract_options!
      column = args.first
      if !block.nil?
        self.resource_identifier = block
      elsif !column.nil?
        if !opts.empty? && ( opts.has_key?(:if) || opts.has_key?(:unless) )
          if opts[:unless] == :id_numeric
            opts[:unless] = lambda { |id| id =~ /^[0-9]+$/ }
          end
          
          # Negate the condition to generate an :if from an :unless.
          condition = opts[:if] || lambda { |id| not opts[:unless].call(id) }
          
          self.resource_identifier = lambda do |id|
            if condition.call(id)
              column
            else :id end
          end
        else
          self.resource_identifier = column
        end
      else
        raise ArgumentError, "identified_by expects either a block or a column name and some options"
      end
    end
    
    # The class of the model exposed by this resource.  Derived from the model name.  See +exposes+.
    def model_class
      @model_class ||= model_name.camelize.constantize
    end

    # Indicates that the CRUD methods should be called on the given class.  Accepts
    # either a class object or the name of the desired model.
    def exposes(model_class)
      remove_retrieval_methods!
      @model_class = model_class.to_s.singularize.camelize.constantize
      alias_retrieval_methods!
    end
        
    # Renders the resource as XML.
    def to_xml(opts={})
      { :name       => self.controller_name,
        :parameters => self.queryable_params,
        :identifier => self.xml_identifier
      }.to_xml(opts.merge(:root => "resource"))
    end
    
    protected
    
      def xml_identifier
        (self.resource_identifier.is_a?(Proc) ? self.resource_identifier.call(nil) : self.resource_identifier).to_s
      end
        
    private
        
      def alias_retrieval_methods!
        define_method("new_#{model_name}")                 { new_model_object }
        define_method("find_#{model_name}")                { find_model_object }
        define_method("create_#{model_name}")              { create_model_object }
        define_method("update_#{model_name}")              { update_model_object }
        define_method("destroy_#{model_name}")             { destroy_model_object }
        define_method("find_all_#{model_name.pluralize}")  { find_all_model_objects }
        define_method("count_all_#{model_name.pluralize}") { count_all_model_objects }
      end
      
      def remove_retrieval_methods!
        remove_method "new_#{model_name}"
        remove_method "find_#{model_name}"
        remove_method "create_#{model_name}"
        remove_method "update_#{model_name}"
        remove_method "destroy_#{model_name}"
        remove_method "find_all_#{model_name.pluralize}"
        remove_method "count_all_#{model_name.pluralize}"
      end
  end
end