require 'spec_helper'

describe FacebookUser do
  context 'authenticated' do
    it 'is not authenticated if access token is not available' do
      user = FacebookUser.new('')
      user.should_not be_authenticated
    end

    it 'is authenticate if access token is available' do
      user = FacebookUser.new('access_token')
      user.should be_authenticated
    end
  end

  it 'fetches profile using access token' do
    user = FacebookUser.new('access_token')
    client = FacebookClient.new
    FacebookClient.should_receive(:new).and_return(client)
    response = double('Response', deserialise: { name: 'Booga' })
    client.should_receive(:authorized_get).with('/me', 'access_token').and_return(response)
    profile = user.profile
    profile.name.should == 'Booga'
  end
end
