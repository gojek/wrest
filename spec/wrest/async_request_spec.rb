# frozen_string_literal: true
require 'spec_helper'

module Wrest
  describe AsyncRequest do
    context 'default_to_em!' do
      it 'changes the default backend for asynchronous requests to eventmachine' do
        AsyncRequest.default_to_em!
        expect(AsyncRequest.default_backend).to be_an_instance_of(AsyncRequest::EventMachineBackend)
      end
    end

    context 'default_to_threads!' do
      it 'changes the default backend for asynchronous requests to threads' do
        AsyncRequest.default_to_threads!
        expect(AsyncRequest.default_backend).to be_an_instance_of(AsyncRequest::ThreadBackend)
      end
    end

    context 'default_backend=' do
      it 'changes the default backend to the given backend' do
        AsyncRequest.enable_em
        AsyncRequest.default_backend = AsyncRequest::EventMachineBackend.new
        expect(AsyncRequest.default_backend).to be_an_instance_of(AsyncRequest::EventMachineBackend)
      end
    end
  end
end
