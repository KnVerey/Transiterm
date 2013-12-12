class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :term_records, dependent: :destroy
end
