# frozen_string_literal: true

require 'spec_helper'

module Wrest
  describe HttpCodes do
    http_backends = { 'Wrest::Native::Response' => 'Net::HTTPResponse' }

    http_backends.each do |klass, double_class|
      { '200' => 'OK', '201' => 'CREATED', '202' => 'ACCEPTED', '204' => 'NO CONTENT',
        '301' => 'MOVED PERMANENTLY', '302' => 'FOUND', '303' => 'SEE OTHER', '304' => 'NOT MODIFIED',
        '307' => 'TEMPORARY REDIRECT', '400' => 'BAD REQUEST', '401' => 'UNAUTHORIZED',
        '403' => 'FORBIDDEN', '404' => 'NOT FOUND', '405' => 'METHOD_NOT_ALLOWED',
        '406' => 'NOT_ACCEPTABLE', '422' => 'UNPROCESSABLE ENTITY',
        '500' => 'INTERNAL SERVER ERROR' }.each do |status, status_message|
        it "knows if the response code is HTTP #{status_message} for #{klass} object" do
          code = status
          method = (status_message.split.join('_').downcase + '?').to_sym
          net_response = double(double_class)
          allow(net_response).to receive(:code).and_return(code)
          allow(net_response).to receive(:headers).and_return({})
          allow(net_response).to receive(:status).and_return(code)
          klass.constantize.send(:new, net_response).send(method).should be_truthy
        end

        it "knows if the response code is not HTTP #{status_message} for #{klass} object" do
          code = (status.to_i + 1).to_s
          method = (status_message.split.join('_').downcase + '?').to_sym
          net_response = double(double_class)
          allow(net_response).to receive(:code).and_return(code)
          allow(net_response).to receive(:headers).and_return({})
          allow(net_response).to receive(:status).and_return(code)
          klass.constantize.send(:new, net_response).send(method).should be_falsey
        end
      end
    end
  end
end
