class Ooga < ActiveRecord::Base
  has_many :comments, :as => :commentworthy
end
