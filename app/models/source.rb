class Source < ActiveRecord::Base
	include PgSearch

	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true
	validates :name, uniqueness: { scope: :user_id }

	def self.destroy_if_orphaned(id)
		source = Source.find(id)
		source.destroy if source.orphaned?
	end

	def self.orphans
		Source.all.select { |r| r.term_records.empty? }
	end

	def orphaned?
		self.term_records.empty?
	end
end
