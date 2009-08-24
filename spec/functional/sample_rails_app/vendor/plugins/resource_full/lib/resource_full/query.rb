module ResourceFull
  module Query    
    class << self      
      def included(base)
        super(base)
        base.send :extend, ClassMethods
        base.queryable_with :limit,  :scope => lambda {|limit|  { :limit  => limit  }}
        base.queryable_with :offset, :scope => lambda {|offset| { :offset => offset }}
        base.queryable_with_order
      end
    end
    
    # A Parameter represents the information necessary to describe a query relationship.  It's inherently
    # tied to ActiveRecord at the moment, unfortunately.  Objects of this class should not be instantiated
    # directly; instead, use the +queryable_with+ method.
    class Parameter
      attr_reader :name, :resource
    
      def initialize(name, resource, opts={})
        @name      = name
        @resource  = resource
        @fuzzy     = opts[:fuzzy] || false
        @allow_nil = opts[:allow_nil] || false
        @default_value = opts[:default]
      end
      
      def fuzzy?; @fuzzy; end
      def allow_nil?; @allow_nil; end
      
      def to_xml(opts={})
        {
          :name => name.to_s,
          :resource => resource.model_name.pluralize,
          :fuzzy => fuzzy?,
        }.to_xml(opts.merge(:root => "parameter"))
      end
      
      def applicable_to?(request_params)
        if allow_nil?
          request_params.has_key?(self.name.to_s) || request_params.has_key?(self.name.to_s.pluralize)
        else
          not param_values_for(request_params).blank?
        end
      end
      
      def find(finder, request_params)
        raise NotImplementedError, "Subclasses implement this behavior."
      end
      
      def subclass(new_resource)
        raise NotImplementedError, "Subclasses implement this behavior."
      end
      
      protected
      
        def param_values_for(params)
          values = (params[self.name.to_s] || params[self.name.to_s.pluralize] || @default_value || '')
          values = values.to_s.split(',') unless values.is_a?(Array)
          values.map! {|value| "%#{value}%" } if fuzzy?
          values
        end
        
        def table_for(opts={})
          if opts.has_key?(:table)
            opts[:table]
          elsif opts.has_key?(:from)
            infer_model_from(resource.model_class, opts[:from]).table_name
          else
            resource.model_class.table_name
          end
        end
        
        def infer_model_from(model, join)
          if join.is_a? Symbol
            model.reflect_on_association(join).klass
          elsif join.is_a? Hash
            new_model = model.reflect_on_association(join.keys.first).klass
            infer_model_from new_model, join.values.first
          end
        end
      
    end
        
    class CustomParameter < Parameter
      attr_reader :table, :columns, :include

      def initialize(name, resource, opts={})
        super(name, resource, opts)
        
        @table     = table_for(opts)
        @columns   = columns_for(name, resource, opts)
        @negated   = opts[:negated] || false
        @include   = opts[:from] || []
      end
      
      def allow_nil?; @allow_nil; end
      def negated?; @negated; end
      
      def find(finder, request_params)
        return finder unless applicable_to?(request_params)
        finder.scoped :conditions => conditions_for(request_params), :include => @include
      end
      
      def subclass(new_resource)
        new_table = if @table == @resource.model_class.table_name
          new_resource.model_class.table_name
        else @table end
          
        self.class.new(@name, new_resource,
          :fuzzy     => @fuzzy,
          :allow_nil => @allow_nil,
          :table     => new_table,
          :columns   => @columns,
          :from      => @include,
          :negated   => @negated
        )
      end
      
      private
      
        def conditions_for(params)
          values = param_values_for(params)
          unless values.empty?
            final_query_string = if negated?
              values.collect { |value| negated_query_string(value) }.join(" AND ")
            else
              values.collect { |value| query_string(value) }.join(" OR ")
            end

            final_values       = values.sum([]) { |value| Array.new(columns.size, value) }

            [ final_query_string ] + final_values
          else
            if (allow_nil? && params.has_key?(self.name) && params[self.name].blank?)
              [query_string(params[self.name])]
            else
              []
            end
          end
        end
          
        def columns_for(name, resource, opts={})
          if opts.has_key?(:columns)
            opts[:columns]
          elsif opts.has_key?(:column)
            [ opts[:column] ]
          elsif opts[:resource_identifier] && opts.has_key?(:from)
            [ ResourceFull::Base.controller_for(infer_model_from(resource.model_class, opts[:from]).name.pluralize).resource_identifier ]
          else
            [ name ]
          end
        end
      
        def query_string(value)
          columns.collect do |column|
            # Convert to a column name if column is a proc. TODO There must be a cleaner way to do this.
            column = column.call(value) if column.is_a?(Proc)
            if fuzzy?
              "(#{table}.#{column} LIKE ?)"
            elsif !value.blank?
              "(#{table}.#{column} = ?)"
            elsif allow_nil?
              "(COALESCE(#{table}.#{column},'')='')"
            end
          end.join(" OR ")
        end
        
        def negated_query_string(value)
          columns.collect do |column|
            # Convert to a column name if column is a proc. TODO There must be a cleaner way to do this.
            column = column.call(value) if column.is_a?(Proc)
            if fuzzy?
              "(#{table}.#{column} NOT LIKE ? OR #{table}.#{column} IS NULL)"
            elsif !value.blank?
              "(#{table}.#{column} != ? OR #{table}.#{column} IS NULL)"
            end
          end.join(" AND ")
        end
    end
    
    class ScopedParameter < Parameter
      attr_reader :scope
      
      def initialize(name, resource, opts={})
        super(name, resource, opts)
        @scope = opts[:scope]
      end
      
      def method_scoped?; @scope.is_a?(Symbol); end
      def proc_scoped?; @scope.is_a?(Proc); end
      def hash_scoped?; @scope.is_a?(Hash); end
      
      def find(finder, request_params)        
        return finder unless applicable_to?(request_params)
        
        if proc_scoped?
          finder.scoped scope.call(*param_values_for(request_params))
        elsif hash_scoped?
          finder.scoped scope
        else
          finder.send(scope, *param_values_for(request_params))
        end
      end
      
      def subclass(new_resource)
        self.class.new @name, new_resource, :scope => @scope
      end
      
    end
    
    class OrderParameter < Parameter
      
      def applicable_to?(request_params)
        request_params.has_key?(:order_by)
      end
      
      def natural_sort_for(opts)
        if opts.has_key?(:natural_sort)
          opts[:natural_sort]
        else
          false
        end
      end
  
      def find(finder, request_params)
        return finder unless applicable_to?(request_params)
    
        order_by = request_params[:order_by]
        order_direction = request_params[:order_direction] || "asc"
        sort_params = resource.orderables[order_by.to_sym] || {}
        table = table_for(sort_params)
        column = sort_params[:column] || order_by
    
        order_params = returning({}) do |hash|
          hash[:include] = sort_params[:from]
        end
    
        if natural_sort_for(sort_params)
          # to use this natural sort you must follow these instructions: http://www.ciarpame.com/2008/06/28/true-mysql-natural-order-by-trick/
          finder.scoped order_params.merge( :order => "natsort_canon(#{table}.#{column}, 'natural') #{order_direction}" )
        else
          finder.scoped order_params.merge( :order => "#{table}.#{column} #{order_direction}" )
        end
      end
      
      def subclass(new_resource)
        self.class.new(@name, new_resource)
      end
      
    end
    
    module ClassMethods
      # Indicates that the resource should be queryable with the given parameters, which will be pulled from
      # the params hash on an index or count call.  Accepts the following options:
      # 
      #   * :fuzzy => true : Use a LIKE query instead of =.
      #   * :columns / :column => ... : Override the default column, or provide a list of columns to query for this value.
      #   * :from => :join_name : Indicate that this value should be queried by joining on another model.  Should use
      #     a valid relationship from this controller's exposed model (e.g., :account if belongs_to :account is specified.)
      #   * :resource_identifier => true : Try to look up the resource controller for this value and honor its
      #     specified resource identifier.  Useful for nesting relationships.
      #   * :allow_nils => true : Indicates that a nil value for a parameter should be taken to literally indicate
      #     that null values should be returned.  This may be changed in the future to expect the literal string 'null'
      #     or some other reasonable standin.
      #
      # Examples:
      #
      #   queryable_with :user_id
      #   queryable_with :description, :fuzzy => true
      #   queryable_with :name, :columns => [:first_name, :last_name]
      #   queryable_with :street_address, :from => :address, :column => :street
      #
      # TODO No full-text search support.
      def queryable_with(*args)
        opts = args.extract_options!
        opts.assert_valid_keys :default, :fuzzy, :column, :columns, :from, :table, :resource_identifier, :allow_nil, :negated, :scope
        args.each do |param|
          self.queryable_params << if opts.has_key?(:scope)
            ResourceFull::Query::ScopedParameter.new(param, self, opts)
          else
            ResourceFull::Query::CustomParameter.new(param, self, opts)
          end
        end
      end
      
      # :nodoc:
      def clear_queryable_params!
        @queryable_params = []
      end
      
      # All queryable parameters.  Objects are of type +ResourceFull::Query::Parameter+ or one of its subclasses.
      def queryable_params
        unless defined?(@queryable_params) && !@queryable_params.nil?
          @queryable_params = []
          if superclass.respond_to?(:queryable_params)
            @queryable_params += superclass.queryable_params.collect {|param| param.subclass(self)}
          end
        end
        @queryable_params
      end
      
      # Returns true if the controller is queryable with all of the named parameters.
      def queryable_with?(*params)
        (queryable_params.collect(&:name) & params.collect(&:to_sym)).size == params.size
      end
      
      # :nodoc:
      def queryable_params=(params)
        @queryable_params = params
      end
      
      def nests_within(*resources)
        resources.each do |resource|
          expected_nest_id = "#{resource.to_s.singularize}_id"
          queryable_with expected_nest_id, :from => resource.to_sym, :resource_identifier => true
        end
      end
      
      def orderable_by(*params)
        opts = params.extract_options!
        params.each do |param|
          orderables[param] = opts
        end
      end
      
      def queryable_with_order
        unless queryable_with?(:order_by)
          queryable_params << ResourceFull::Query::OrderParameter.new(:order_by, self)
        end
      end
            
      def orderables
        read_inheritable_attribute(:orderables) || write_inheritable_hash(:orderables, {})
      end
    end
  end
end