class Collection < ActiveRecord::Base
	belongs_to :user
  has_one :language_pair
end
