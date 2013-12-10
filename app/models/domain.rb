class Domain < ActiveRecord::Base
	belongs_to :user
	has_many :term_records
end
