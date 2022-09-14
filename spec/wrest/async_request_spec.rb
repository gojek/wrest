# frozen_string_literal: true

require 'spec_helper'

module Wrest
  describe AsyncRequest do
    context 'default_to_em!' do
      it 'changes the default backend for asynchronous requests to eventmachine' do
        described_class.default_to_em!
        expect(described_class.default_backend).to be_an_instance_of(AsyncRequest::EventMachineBackend)
      end
    end

    context 'default_to_threads!' do
      it 'changes the default backend for asynchronous requests to threads' do
        described_class.default_to_threads!
        expect(described_class.default_backend).to be_an_instance_of(AsyncRequest::ThreadBackend)
      end
    end

    context 'default_backend=' do
      it 'changes the default backend to the given backend' do
        described_class.enable_em
        described_class.default_backend = AsyncRequest::EventMachineBackend.new
        expect(described_class.default_backend).to be_an_instance_of(AsyncRequest::EventMachineBackend)
      end
    end
  end
end
