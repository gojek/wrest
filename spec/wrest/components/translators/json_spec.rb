# frozen_string_literal: true
require 'spec_helper'

module Wrest::Components::Translators
  describe Json do
    let(:http_response) { double('Http Reponse') }

    it 'knows how to convert json to a hashmap' do
      http_response.should_receive(:body).and_return("{
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
                                { 'title' => 'Open', 'action' => 'OpenDoc' }, { 'title' => 'Close', 'action' => 'CloseDoc' }],
                 'menu' => 'File' }
      Json.deserialise(http_response).should eq(result)
    end

    it 'knows how to convert json to a hashmap' do
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
      expect(Json.serialise(hash)).to include('"menu":"File"')
      expect(Json.serialise(hash)).to include('"commands":[{"title":"New","action":"CreateDoc"},{"title":"Open","action":"OpenDoc"},{"title":"Close","action":"CloseDoc"}]')
    end

    it 'has #deserialize delegate to #deserialise' do
      expect(Json).to receive(:deserialise).with(http_response, hash_including(option: :something))
      Json.deserialize(http_response, option: :something)
    end

    it 'has #serialize delegate to #serialise' do
      expect(Json).to receive(:serialise).with({ hash: :foo }, hash_including(option: :something))
      Json.serialize({ hash: :foo }, option: :something)
    end
  end
end
