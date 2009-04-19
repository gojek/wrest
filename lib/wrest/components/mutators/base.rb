# Copyright 2009 Sidu Ponnappa

# Licensed under the Apache License, Version 2.0 (the "License"); 
# you may not use this file except in compliance with the License. 
# You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0 
# Unless required by applicable law or agreed to in writing, software distributed under the License 
# is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
# See the License for the specific language governing permissions and limitations under the License. 

# This is a Null Object implementation of a
# hash mutator that will leave the contents
# of any hash it is applied to unchanged.
class Wrest::Components::Mutators::Base
  # This method operates on a tuple (well, pair)
  # from a hash map.
  # Iterating over any hash using each injects
  # each key/value pair from the hash in the
  # form of an array.
  # Thus the tuple this method expects 
  # is simply [:key, :value]
  #
  # Since this is a Null Object, this method
  # simply returns the tuple unchanged
  def mutate(tuple)
    tuple
  end
end