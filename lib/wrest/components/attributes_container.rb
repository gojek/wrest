# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest::Components #:nodoc:

  # Adds behaviour allowing a class to
  # contain attributes and providing support
  # for dynamic getters, setters and query methods.
  # These methods are added at runtime, on the first
  # invocation and on a per instance basis.   
  # <tt>respond_to?</tt> however will respond as though 
  # they are all already present.
  # This means that two different instances of the same 
  # AttributesContainer could well have
  # different attribute getters/setters/query methods.
  #
  # Note that the first call to a particular getter/setter/query
  # method will be slower because the method is defined
  # at that point; subsequent calls will be much faster.
  #
  # Also keep in mind that attribute getter/setter/query methods
  # will _not_ override any existing methods on the class.
  #
  # In situations where this is a problem, such as a client consuming Rails
  # REST services where <tt>id</tt> is a common attribute and clashes with
  # Object#id, it is recommended to create getter/setter/query methods
  # on the class (which affects all instances) using the +has_attributes+ macro. 
  #
  # If you're implementing your own initialize method
  # remember to delegate to the default initialize 
  # of AttributesContainer by invoking <tt>super(attributes)</tt>
  #
  # Example:
  #  class ShenCoin
  #    include Wrest::Components::AttributesContainer
  #
  #    has_attributes  :id
  #    typecast        :id => as_integer
  #  end 
  #  coin = ShenCoin.new(:id => '5', :chi_count => 500, :owner => 'Kai Wren')
  #  coin.id    # => 5
  #  coin.owner # => 'Kai Wren'
  module AttributesContainer
    def self.included(klass) #:nodoc:
      klass.extend AttributesContainer::ClassMethods
      klass.extend TypecastHelpers
      klass.class_eval{ include AttributesContainer::InstanceMethods }
    end
    
    def self.build_attribute_getter(attribute_name) #:nodoc:
      "def #{attribute_name};@attributes[:#{attribute_name}];end;"
    end
    
    def self.build_attribute_setter(attribute_name) #:nodoc:
      "def #{attribute_name}=(value);@attributes[:#{attribute_name}] = value;end;"
    end
    
    def self.build_attribute_queryer(attribute_name) #:nodoc:
      "def #{attribute_name}?;not @attributes[:#{attribute_name}].nil?;end;"
    end
    
    module ClassMethods
      # This macro explicitly creates getter, setter and query methods on
      # a class, overriding any exisiting methods with the same names. 
      # This can be used when attribute names clash with method names;
      # an example would be Rails REST services which frequently make use
      # an attribute named <tt>id</tt> which clashes with Object#id. Also,
      # this can be used as a performance optimisation if the incoming
      # attributes are known beforehand.
      def has_attributes(*attribute_names)
        attribute_names.each do |attribute_name|
          self.class_eval(
            AttributesContainer.build_attribute_getter(attribute_name) +
            AttributesContainer.build_attribute_setter(attribute_name) +
            AttributesContainer.build_attribute_queryer(attribute_name)
          ) 
        end
      end
      
      # Accepts a set of attribute-name/lambda pairs which are used
      # to typecast string values injected through the constructor.
      # Typically needed when populating an +AttributesContainer+
      # directly from request params. Typecasting kicks in for
      # a given value _only_ if it is a string.
      #
      # Typcast information is inherited by subclasses; however be
      # aware that explicitly invoking +typecast+ in a subclass will
      # discard inherited typecast information leaving only the casts
      # defined in the subclass.
      #
      # Common typecasts such as integer, float, datetime etc. are
      # available through predefined helpers. See TypecastHelpers
      # for a full list.
      #
      # Example:
      #
      #  class Demon
      #    include Wrest::Components::AttributesContainer
      #    typecast :age  =>  as_integer,
      #             :chi  =>  lambda{|chi| Chi.new(chi)}  
      #  end
      #  kai_wren = Demon.new('age' => '1500', 'chi' => '1024')
      #  kai_wren.age # => 1500   
      #  kai_wren.chi # => #<Chi:0x113af8c @count="1024">   
      def typecast(cast_map)
        @typecast_map = @typecast_map ? @typecast_map.merge(cast_map.symbolize_keys) : cast_map.symbolize_keys
      end
      
      def typecast_map #:nodoc:
        if defined?(@typecast_map)
          @typecast_map
        elsif superclass != Object && superclass.respond_to?(:typecast_map)
          superclass.typecast_map
        else
          {}  
        end
      end  
    end
       
    module InstanceMethods
      # Sets up any class to act like
      # an attributes container by creating
      # two variables, @attributes and @interface.
      # Remember not to use these two variable names
      # when using AttributesContainer in your
      # own class.
      def initialize(attributes = {})
        @attributes = attributes.symbolize_keys
        self.class.typecast_map.each do |key, typecaster|
          value = @attributes[key]
          @attributes[key] = typecaster.call(value) if value.is_a?(String)
        end
        @interface = Module.new
        self.extend @interface
      end
      
      def [](key)
        @attributes[key.to_sym]
      end
      
      def []=(key, value)
        @attributes[key.to_sym] = value
      end
      
      def respond_to?(method_name, include_private = false)
        super(method_name, include_private) ? true : @attributes.include?(method_name.to_s.gsub(/(\?$)|(=$)/, '').to_sym)
      end

      # Creates getter, setter and query methods for
      # attributes on the first call.
      def method_missing(method_sym, *arguments)
        method_name = method_sym.to_s
        attribute_name = method_name.gsub(/(\?$)|(=$)/, '')

        if @attributes.include?(attribute_name.to_sym) || method_name.last == '='
          case method_name.last
          when '='
            @interface.module_eval AttributesContainer.build_attribute_setter(attribute_name)
          when '?'
            @interface.module_eval AttributesContainer.build_attribute_queryer(attribute_name)
          else
            @interface.module_eval AttributesContainer.build_attribute_getter(attribute_name)
          end
          send(method_sym, *arguments)
        else
          super(method_sym, *arguments)
        end
      end
      
    end
  end
end
