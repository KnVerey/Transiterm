class Collection < ActiveRecord::Base
	belongs_to :user
  has_one :language_pair
	has_many :term_records, dependent: :destroy
end
