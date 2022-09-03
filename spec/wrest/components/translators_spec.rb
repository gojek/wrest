# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'

module Wrest::Components
  describe Translators do
    it "knows how to raise an exception if the mime type doesn't exist" do
      expect { Translators.lookup('weird/unknown') }.to raise_error(Wrest::Exceptions::UnsupportedContentType)
    end
  end
end
