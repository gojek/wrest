# frozen_string_literal: true

require 'spec_helper'

module Wrest
  module Components
    module Translators
      describe Xml do
        let(:http_response) { double('Http Reponse') }

        it 'knows how to convert xml to a hashmap' do
          expect(http_response).to receive(:body).and_return('<ooga><age>12</age></ooga>')

          expect(described_class.deserialise(http_response)).to eq({ 'ooga' => { 'age' => { '__content__' => '12' } } })
        end

        it 'knows how to convert a hashmap to xml' do
          expected_xml = "<?xml version=\"1.0\"?>\n<ooga>\n  <age>12</age>\n</ooga>\n"

          expect(described_class.serialise({ 'ooga' => { 'age' => '12' } })).to eq(expected_xml)
        end

        it 'calls search only if xpath is specified' do
          xml_body = '<Person></Person>'
          xpath_term = '//age'
          expect(http_response).to receive(:body).and_return(xml_body)
          expect(described_class).to receive(:search).with(kind_of(StringIO), xpath_term)

          described_class.deserialise(http_response, { xpath: xpath_term })
        end

        it 'does not call filter if xpath is not specified' do
          fake_body = '<Person><Personal><Name><FirstName>Nikhil</FirstName></Name></Personal><Address>' \
                      '<Name>Bangalore</Name></Address></Person>'
          expect(http_response).to receive(:body).and_return(fake_body)
          expect(described_class).not_to receive(:filter)

          described_class.deserialise(http_response)
        end

        Helpers.xml_backends.each do |_e|
          it 'is able to pull out desired elements from an xml response based on xpath and return an array of matching nodes' do
            fake_body = '<Person><Personal><Name><FirstName>Nikhil</FirstName></Name></Personal><Address>' \
                        '<Name>Bangalore</Name></Address></Person>'
            expect(http_response).to receive(:body).and_return(fake_body)

            res_arr = described_class.deserialise(http_response, { xpath: '//Name' })
            result = ''
            res_arr.each { |a| result += a.to_s.gsub(/\n+/, '').gsub(/\s/, '') }
            expect(result).to eq('<Name><FirstName>Nikhil</FirstName></Name><Name>Bangalore</Name>')
          end
        end

        it 'has #deserialize delegate to #deserialise' do
          expect(described_class).to receive(:deserialise).with(http_response, hash_including(option: :something))
          described_class.deserialize(http_response, option: :something)
        end

        it 'has #serialize delegate to #serialise' do
          expect(described_class).to receive(:serialise).with({ hash: :foo }, hash_including(option: :something))
          described_class.serialize({ hash: :foo }, option: :something)
        end
      end
    end
  end
end
