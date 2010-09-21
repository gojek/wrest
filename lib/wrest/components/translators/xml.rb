# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.
# require 'jruby'
# include Java
# 
# java_import javax.xml.parsers.DocumentBuilder
# java_import javax.xml.parsers.DocumentBuilderFactory
# java_import java.io.StringReader
# java_import org.xml.sax.InputSource
# java_import javax.xml.xpath.XPath
# java_import javax.xml.xpath.XPathFactory
# java_import javax.xml.xpath.XPathConstants
# java_import javax.xml.xpath.XPathExpression
# #java_import Java::org.jdom.input.SAXBuilder
module Wrest
  module Components::Translators
    module Xml
      extend self

      def deserialise(response,options={})
        if(!options[:xpath].nil?)
          Hash.from_xml(filter(response,options[:xpath]))
        else
          Hash.from_xml(response.body)
        end
      end

      def serialise(hash, options = {})
        hash.to_xml(options)
      end

      def filter(response,xpath)
        filter_rexml(response,xpath)
      end
      
      def filter_rexml(response,xpath)
        doc = REXML::Document.new(response.body)
        REXML::XPath.first(doc,xpath).to_s
      end


      # def filter_jdom(response,xpath)
      #  # string_reader = StringReader.new(response.body)
      #   input_source = InputSource.new(string_reader)
      #   #p input_source.to_s
      #   doc = DocumentBuilderFactory.new_instance.new_document_builder.parse(input_source)
      #   #doc = SAXBuilder.new.build(string_reader)
      #   p doc
      #   p doc.toString
      #   #xpath_instance = XPathFactory.new_instance.newXPath
      #   #expr = xpath_instance.compile(xpath)
      #   #p expr.to_s
      #   #result = expr.evaluate(doc)

      #   #puts result
      # end

    end
  end
end
