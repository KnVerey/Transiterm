class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :term_records, dependent: :destroy

	validates :title, presence: true

end
