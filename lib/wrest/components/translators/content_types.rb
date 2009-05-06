# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

module Wrest
  module Components::Translators
    # Maps content types to deserialisers
    CONTENT_TYPES = {
      'application/xml' => Wrest::Components::Translators::Xml,
      'text/xml' => Wrest::Components::Translators::Xml,
      'application/json' => Wrest::Components::Translators::Json,
      'text/javascript' => Wrest::Components::Translators::Json
    }
  end
end