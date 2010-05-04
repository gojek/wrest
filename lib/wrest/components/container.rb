# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

module Wrest
  module Components::Container
  end
end

require "#{Wrest::Root}/wrest/components/container/typecaster"
require "#{Wrest::Root}/wrest/components/container/alias_accessors"

module Wrest::Components

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
  # on the class (which affects all instances) using the +always_has+ macro.
  #
  # If you're implementing your own initialize method
  # remember to delegate to the default initialize
  # of AttributesContainer by invoking <tt>super(attributes)</tt>
  #
  # Example:
  #  class ShenCoin
  #    include Wrest::Components::AttributesContainer
  #    include Wrest::Components::AttributesContainer::Typecaster
  #
  #    always_has   :id
  #    typecast         :id   =>  as_integer
  #  end
  #  coin = ShenCoin.new(:id => '5', :chi_count => 500, :owner => 'Kai Wren')
  #  coin.id    # => 5
  #  coin.owner # => 'Kai Wren'
  module Container
    def self.included(klass) #:nodoc:
      klass.extend Container::ClassMethods
      klass.extend Container::Typecaster::Helpers
      klass.class_eval do 
        include Container::InstanceMethods
        include Container::AliasAccessors
      end  
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
      # an AttributesContainer, overriding any exisiting methods with the same names.
      # This can be used when attribute names clash with existing method names;
      # an example would be Rails REST resources which frequently make use
      # an attribute named <tt>id</tt> which clashes with Object#id. Also,
      # this can be used as a performance optimisation if the incoming
      # attributes are known beforehand.
      def always_has(*attribute_names)
        attribute_names.each do |attribute_name|
          self.class_eval(
          Container.build_attribute_getter(attribute_name) +
          Container.build_attribute_setter(attribute_name) +
          Container.build_attribute_queryer(attribute_name)
          )
        end
      end
      
      # This is a convenience macro which includes 
      # Wrest::Components::AttributesContainer::Typecaster into
      # the class (effectively overwriting this method) before delegating to 
      # the actual typecast method that is a part of that module.
      # This saves us the effort of explicitly doing the include. Easy to use API is king.
      #
      # Remember that using typecast carries a performance penalty.
      # See Wrest::Components::AttributesContainer::Typecaster for the actual docs.
      def typecast(cast_map)
        self.class_eval{ include Wrest::Components::Container::Typecaster }
        self.typecast cast_map
      end
      
      # This is the name of the class in snake-case, with any parent
      # module names removed.
      #
      # The class will use as the root element when
      # serialised to xml after replacing underscores with hyphens.
      #
      # This method can be overidden should you need a different name.
      def element_name
        @element_name ||= ActiveSupport::Inflector.demodulize(self.name).underscore.underscore
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
      end
      
      # A translator is a anything that knows how to serialise a
      # Hash. It must needs have a method named 'serialise' that
      # accepts a hash and configuration options, and returns the serialised 
      # result (leaving the hash unchanged, of course).
      #
      # Examples for JSON and XML can be found under Wrest::Components::Translators.
      # These serialised output of these translators will work out of the box for Rails 
      # applications; you may need to roll your own for anything else.
      #
      # Note: When serilising to XML, if you want the name of the class as the name of the root node
      # then you should use the AttributesContainer#to_xml helper.
      def serialise_using(translator, options = {})
        translator.serialise(@attributes, options)
      end
      
      def to_xml(options = {})
        serialise_using(Wrest::Components::Translators::Xml, {:root => self.class.element_name}.merge(options))
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
        if @attributes.include?(attribute_name.to_sym) || method_name.last == '=' || method_name.last == '?'
          case method_name.last
          when '='
            self.instance_eval Container.build_attribute_setter(attribute_name)
          when '?'
            self.instance_eval Container.build_attribute_queryer(attribute_name)
          else
            self.instance_eval Container.build_attribute_getter(attribute_name)
          end
          send(method_sym, *arguments)
        else
          super(method_sym, *arguments)
        end
      end
    end
  end
end
