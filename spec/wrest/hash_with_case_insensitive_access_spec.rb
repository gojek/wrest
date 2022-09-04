# frozen_string_literal: true

require 'spec_helper'

module Wrest
  describe HashWithCaseInsensitiveAccess do
    before do
      @hash = described_class.new 'FOO' => 'bar', 'baz' => 'bee', 22 => 2002, :xyz => 'pqr'
    end

    it 'has values accessible irrespective of case' do
      expect(@hash['foo']).to eq('bar')
      expect(@hash['Foo']).to eq('bar')

      expect(@hash.values_at('foo', 'bAZ')).to eq(%w[bar bee])
      expect(@hash.delete('FOO')).to eq('bar')
    end

    it 'merges keys independent irrespective of case' do
      @hash.merge!('force' => false, 'bAz' => 'boom')
      expect(@hash['force']).to be(false)
      expect(@hash['baz']).to eq('boom')
    end

    it 'creates a new hash by merging keys irrespective of case' do
      other = @hash.merge('force' => false, :baz => 'boom')
      expect(other['force']).to be(false)
      expect(other['FORCE']).to be(false)
      expect(other[:baz]).to eq('boom')
    end

    it 'works normally for non-string keys' do
      expect(@hash[22]).to eq(2002)
      expect(@hash[:xyz]).to eq('pqr')
    end
  end
end
