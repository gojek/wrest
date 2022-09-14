# frozen_string_literal: true

module Wrest
  module Components
    module Translators
      module Xml
        module Conversions # :nodoc:
          module Document # :nodoc:
            def to_hash
              root.to_hash
            end
          end

          module Node # :nodoc:
            CONTENT_ROOT = '__content__'

            # Convert XML document to hash.
            #
            # hash::
            #   Hash to merge the converted element into.
            def to_hash(hash = {})
              node_hash = {}

              # Insert node hash into parent hash correctly.
              case hash[name]
              when Array then hash[name] << node_hash
              when Hash then hash[name] = [hash[name], node_hash]
              when nil then hash[name] = node_hash
              end

              # Handle child elements
              children.each do |c|
                if c.element?
                  c.to_hash(node_hash)
                elsif c.text? || c.cdata?
                  node_hash[CONTENT_ROOT] ||= +''
                  node_hash[CONTENT_ROOT] << c.content
                end
              end

              # Remove content node if it is blank and there are child tags
              node_hash.delete(CONTENT_ROOT) if node_hash.length > 1 && Utils.object_blank?(node_hash[CONTENT_ROOT])

              # Handle attributes
              attribute_nodes.each { |a| node_hash[a.node_name] = a.value }

              hash
            end
          end
        end
        Nokogiri::XML::Document.include(Conversions::Document)
        Nokogiri::XML::Node.include(Conversions::Node)
      end
    end
  end
end
