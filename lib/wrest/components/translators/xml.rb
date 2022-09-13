# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require_relative 'xml/conversions'

module Wrest
  module Components
    module Translators
      module Xml
        module_function

        def deserialise(response, options = {})
          data = response.body
          data = StringIO.new(data || '') unless data.respond_to?(:read)
          return {} if data.eof?

          if options[:xpath].nil?
            parse(data)
          else
            search(data, options[:xpath])
          end
        end

        def deserialize(response, options = {})
          deserialise(response, options)
        end

        def serialise(hash, _options = {})
          to_xml(hash)
        end

        def serialize(hash, options = {})
          serialise(hash, options)
        end

        def to_xml(hash, builder = nil)
          builder ||= Nokogiri::XML::Builder.new
          hash.each_with_object(builder) do |(key, value), inner_builder|
            if value.is_a?(Hash)
              inner_builder.send(key.to_s) do |child_builder|
                to_xml(value, child_builder)
              end
            else
              inner_builder.send(key.to_s, value.to_s)
            end
          end.to_xml
        end

        # Parse an XML Document string or IO into a simple hash using libxml / nokogiri.
        # data::
        #   XML Document string or IO to parse
        def parse(data)
          build_nokogiri_doc(data).to_hash
        end

        def search(data, xpath)
          build_nokogiri_doc(data).xpath(xpath)
        end

        def build_nokogiri_doc(data)
          doc = Nokogiri::XML(data)
          raise doc.errors.join("\n") if doc.errors.length.positive?

          doc
        end
      end
    end
  end
end
