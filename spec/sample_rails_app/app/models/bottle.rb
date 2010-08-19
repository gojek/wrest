class Bottle < ActiveRecord::Base
  has_many :comments, :as => :commentworthy
end
  