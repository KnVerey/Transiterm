class Domain < ActiveRecord::Base
	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true
end
