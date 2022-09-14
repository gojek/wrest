# frozen_string_literal: true

require 'spec_helper'

module Wrest
  module Components
    module Translators
      describe Txt do
        let(:http_response) { double('Http Reponse') }

        it 'returns response body when deserialise' do
          expect(http_response).to receive(:body).and_return('Homebrew is the easiest.')

          expect(described_class.deserialise(http_response)).to eq('Homebrew is the easiest.')
        end

        it 'returns string version of any object when serialise' do
          expect(described_class.serialise({ 'ooga' => { 'age' => '12' } })).to eq('{"ooga"=>{"age"=>"12"}}')
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
