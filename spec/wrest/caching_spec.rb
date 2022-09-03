require 'spec_helper'

module Wrest
  describe Caching do
    context 'default_to_hash!' do
      it 'changes the default store for caching to ruby hash' do
        Caching.default_to_hash!
        expect(Caching.default_store).to be_an_instance_of(Hash)
      end
    end

    context 'default_to_memcached!' do
      it 'changes the default store for caching to memcached' do
        Caching.default_to_memcached!
        expect(Caching.default_store).to be_an_instance_of(Wrest::Caching::Memcached)
      end
    end

    it 'default to redis sets redis as the default cache store' do
      Caching.default_to_redis!
      expect(Caching.default_store).to be_an_instance_of(Wrest::Caching::Redis)
    end

    context 'default_store=' do
      it 'changes the default store to the given cache store' do
        Caching.default_store = ({})
        expect(Caching.default_store).to be_an_instance_of(Hash)
      end
    end
  end
end
