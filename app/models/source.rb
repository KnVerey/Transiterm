class Source < ActiveRecord::Base
	include PgSearch

	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true

	def self.orphans
		Source.all.select { |r| r.term_records.empty? }
	end

	def orphaned?
		self.term_records.empty?
	end
end
