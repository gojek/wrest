# frozen_string_literal: true

# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software distributed under the License
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require 'spec_helper'
require 'wrest/components/mutators'

module Wrest
  module Components
    describe Mutators::XmlTypeCaster do
      before do
        @mutator = described_class.new
      end

      # {"lead-bottle"=>{"name"=>{"__content__"=>"Wooz"}, "universe-id"=>{"type"=>"integer", "nil"=>"true"}, "id"=>{"__content__"=>"1", "type"=>"integer"}}}

      it 'typecasts a nil value in a tuple' do
        expect(@mutator.mutate(
                 ['universe-id', { 'type' => 'integer', 'nil' => 'true' }]
               )).to eq(['universe-id', nil])
      end

      it 'leaves a string value in a tuple unchanged' do
        expect(@mutator.mutate(
                 ['name', { '__content__' => 'Wooz' }]
               )).to eq(%w[name Wooz])
      end

      it 'casts an integer value in a tuple' do
        expect(@mutator.mutate(
                 ['id', { 'type' => 'integer', '__content__' => '1' }]
               )).to eq(['id', 1])
      end

      it 'steps into a value if it is a hash' do
        expect(@mutator.mutate(
                 ['ResultSet', {
                   'firstResultPosition' => '1', 'totalResultsReturned' => '1',
                   'xsi:schemaLocation' => 'urn:ooga:on http://api.search.ooga.com/NewsSearchService/V1/NewsSearchResponse.xsd',
                   'totalResultsAvailable' => '23287',
                   'Result' => {
                     'UniqueId' => { '__content__' => '1', 'type' => 'integer' },
                     'PublishDate' => { '__content__' => '20090424', 'type' => 'date' },
                     'Language' => { '__content__' => 'en' },
                     'Title' => { '__content__' => 'Wootler: Wook focus should be Klingon, not India' },
                     'ClickUrls' => [
                       { 'One' => { '__content__' => 'http://news.ooga.com/s/ap/20090424/ap_on_go_ca_st_pe/us_us_wookieland_5' } },
                       { 'Two' => { '__content__' => 'http://news.ooga.com/s/ap/20090424/ap_on_go_ca_st_pe/us_us_wookieland_6' } }
                     ]

                   }
                 }]
               )).to eq(['ResultSet', {
                          'firstResultPosition' => '1', 'totalResultsReturned' => '1',
                          'xsi:schemaLocation' => 'urn:ooga:on http://api.search.ooga.com/NewsSearchService/V1/NewsSearchResponse.xsd',
                          'totalResultsAvailable' => '23287',
                          'Result' => {
                            'UniqueId' => 1,
                            'PublishDate' => Date.parse('20090424'),
                            'Language' => 'en',
                            'Title' => 'Wootler: Wook focus should be Klingon, not India',
                            'ClickUrls' => [
                              { 'One' => 'http://news.ooga.com/s/ap/20090424/ap_on_go_ca_st_pe/us_us_wookieland_5' },
                              { 'Two' => 'http://news.ooga.com/s/ap/20090424/ap_on_go_ca_st_pe/us_us_wookieland_6' }
                            ]
                          }
                        }])
      end
    end
  end
end
