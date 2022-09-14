# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Wrest::HashWithIndifferentAccess do
  it 'allows access of string keys using symbols' do
    hash = described_class.new({ 'foo' => 'bar' })
    expect(hash[:foo]).to eq('bar')
  end
end
