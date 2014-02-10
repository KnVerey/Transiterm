class Domain < ActiveRecord::Base
	include PgSearch
	include Searchable

	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true
	validates :name, uniqueness: { scope: :user_id }

	before_save :populate_searchable_fields

	def self.destroy_if_orphaned(id)
		domain = Domain.find(id)
		domain.destroy if domain.orphaned?
	end

	def self.orphans
		Domain.all.select { |r| r.term_records.empty? }
	end

	def orphaned?
		self.term_records.empty?
	end
end
