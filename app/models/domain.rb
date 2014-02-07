class Domain < ActiveRecord::Base
	include PgSearch

	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true
	validates :name, uniqueness: { scope: :user_id }

	def self.orphans
		Domain.all.select { |r| r.term_records.empty? }
	end

	def orphaned?
		self.term_records.empty?
	end

end
