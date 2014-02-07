class Domain < ActiveRecord::Base
	include PgSearch

	belongs_to :user
	has_many :term_records

	validates :name, :user_id, presence: true
	validates :name, uniqueness: { scope: :user_id }

	before_save :set_clean_name

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

	def set_clean_name
		self.clean_name = sanitize(name) if name && name_changed?
	end

	def sanitize(string)
		ActionView::Base.full_sanitizer.sanitize(string.downcase).gsub(/[^\s\w]|_/, "")
	end
end
