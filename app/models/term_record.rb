class TermRecord < ActiveRecord::Base
	include PgSearch

	attr_accessor :domain_name, :source_name

	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	accepts_nested_attributes_for :domain, :source

	validates :collection, presence: { message: "must be selected" }
	validates :domain, presence: { message: "must be specified" }
	validates :source, presence: { message: "must be specified" }

	validate :correct_languages_present

	before_validation :assign_user_on_domain_and_source
	around_destroy :handle_lookup_orphaning
	around_update :handle_lookup_orphaning

	multisearchable against: [:all_sanitized_for_search]

	def all_sanitized_for_search
		combined = ""
		["english", "french", "spanish", "context", "comment"].each do |field|
			value = self.send(field)
			combined << "#{sanitize(value)} " unless value.blank?
		end
		combined << "#{sanitize(self.domain.name)} #{sanitize(self.source.name)}"
	end

	def sanitize(string)
		ActionView::Base.full_sanitizer.sanitize(string.downcase).gsub(/[^\s\w]|_/, "")
	end

	private
	def assign_user_on_domain_and_source
		if collection
			domain.user = collection.user
			source.user = collection.user
		end
	end

	def correct_languages_present
		result = Collection::LANGUAGES.detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all language fields") if result
	end

	def handle_lookup_orphaning
		stale_record = TermRecord.find(self.id)
		yield
		["source", "domain"].each do |field|
			next if self.persisted? && !self.send("#{field}_id_changed?")
			potential_orphan = stale_record.send(field)
			potential_orphan.destroy if potential_orphan.orphaned?
		end
	end
end
