# frozen_string_literal: true

require 'spec_helper'

module Wrest
  module Components
    module Translators
      describe Json do
        let(:http_response) { double('Http Reponse') }

        it 'knows how to convert json to a hashmap' do
          expect(http_response).to receive(:body).and_return("{
      \"menu\": \"File\",
      \"commands\": [
      {
          \"title\": \"New\",
          \"action\":\"CreateDoc\"
      },
      {
          \"title\": \"Open\",
          \"action\": \"OpenDoc\"
      },
      {
          \"title\": \"Close\",
          \"action\": \"CloseDoc\"
      }
      ]
      }")

          result = { 'commands' => [{ 'title' => 'New', 'action' => 'CreateDoc' },
                                    { 'title' => 'Open', 'action' => 'OpenDoc' },
                                    { 'title' => 'Close', 'action' => 'CloseDoc' }],
                     'menu' => 'File' }
          expect(described_class.deserialise(http_response)).to eq(result)
        end

        it 'knows how to convert a hashmap to json' do
          hash = {
            'menu' => 'File',
            'commands' => [{
              'title' => 'New',
              'action' => 'CreateDoc'
            },
                           {
                             'title' => 'Open',
                             'action' => 'OpenDoc'
                           },
                           { 'title' => 'Close', 'action' => 'CloseDoc' }]
          }
          expect(described_class.serialise(hash)).to include('"menu":"File"')
          expect(described_class.serialise(hash)).to include('"commands":[{"title":"New","action":"CreateDoc"},' \
                                                             '{"title":"Open","action":"OpenDoc"},{"title":"Close","action":"CloseDoc"}]')
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
