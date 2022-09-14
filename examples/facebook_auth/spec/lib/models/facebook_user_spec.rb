# frozen_string_literal: true

require 'spec_helper'

describe FacebookUser do
  context 'authenticated' do
    it 'is not authenticated if access token is not available' do
      user = described_class.new('')
      expect(user).not_to be_authenticated
    end

    it 'is authenticate if access token is available' do
      user = described_class.new('access_token')
      expect(user).to be_authenticated
    end
  end

  it 'fetches profile using access token' do
    user = described_class.new('access_token')
    client = FacebookClient.new
    FacebookClient.should_receive(:new).and_return(client)
    response = double('Response', deserialise: { name: 'Booga' })
    client.should_receive(:authorized_get).with('/me', 'access_token').and_return(response)
    profile = user.profile
    expect(profile.name).to eq('Booga')
  end
end
