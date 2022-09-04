# frozen_string_literal: true

require 'spec_helper'

module Wrest
  module Components
    module Translators
      describe Xml do
        let(:http_response) { double('Http Reponse') }

        it 'knows how to convert xml to a hashmap' do
          expect(http_response).to receive(:body).and_return('<ooga><age>12</age></ooga>')

          expect(Xml.deserialise(http_response)).to eq({ 'ooga' => { 'age' => '12' } })
        end

        it 'knows how to convert a hashmap to xml' do
          expect(Xml.serialise({ 'ooga' => { 'age' => '12' } })).to eq("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<hash>\n  <ooga>\n    <age>12</age>\n  </ooga>\n</hash>\n")
        end

        it 'calls filter only if xpath is specified' do
          expect(http_response).to receive(:body)
          expect(ActiveSupport::XmlMini).to receive(:filter)
          Xml.deserialise(http_response, { xpath: '//age' })
        end

        it 'does not call filter if xpath is not specified' do
          fake_body = '<Person><Personal><Name><FirstName>Nikhil</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>'
          expect(http_response).to receive(:body).and_return(fake_body)
          expect(Xml).not_to receive(:filter)

          Xml.deserialise(http_response)
        end

        Helpers.xml_backends.each do |e|
          it 'is able to pull out desired elements from an xml response based on xpath and return an array of matching nodes' do
            ActiveSupport::XmlMini.backend = e

            fake_body = '<Person><Personal><Name><FirstName>Nikhil</FirstName></Name></Personal><Address><Name>Bangalore</Name></Address></Person>'
            expect(http_response).to receive(:body).and_return(fake_body)

            res_arr = Xml.deserialise(http_response, { xpath: '//Name' })
            result = ''
            res_arr.each { |a| result += a.to_s.gsub(/\n+/, '').gsub(/\s/, '') }
            expect(result).to eq('<Name><FirstName>Nikhil</FirstName></Name><Name>Bangalore</Name>')
          end
        end

        it 'has #deserialize delegate to #deserialise' do
          expect(Xml).to receive(:deserialise).with(http_response, hash_including(option: :something))
          Xml.deserialize(http_response, option: :something)
        end

        it 'has #serialize delegate to #serialise' do
          expect(Xml).to receive(:serialise).with({ hash: :foo }, hash_including(option: :something))
          Xml.serialize({ hash: :foo }, option: :something)
        end
      end
    end
  end
end
