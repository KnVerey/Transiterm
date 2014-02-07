class TermRecord < ActiveRecord::Base
	include PgSearch

	attr_accessor :domain_name, :source_name

	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :collection, presence: { message: "must be selected" }
	validates :domain, presence: { message: "must be specified" }
	validates :source, presence: { message: "must be specified" }
	validates :domain_name, presence: { message: "must be specified" }
	validates :source_name, presence: { message: "must be specified" }

	validate :correct_languages_present

	before_validation :assign_domain, :assign_source
	after_save :populate_clean_fields
	after_destroy :prevent_domain_orphaning, :prevent_source_orphaning
	after_update :prevent_domain_orphaning, :prevent_source_orphaning

	def domain_name
		@domain_name || domain.try(:name)
	end

	def source_name
		@source_name || source.try(:name)
	end

	private
	def assign_domain
		self.domain = Domain.find_or_initialize_by(user: collection.user, name: domain_name)
	end

	def assign_source
		self.source = Source.find_or_initialize_by(user: collection.user, name: source_name)
	end

	def correct_languages_present
		result = Collection::LANGUAGES.detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all language fields") if result
	end

	def populate_clean_fields
		["english", "french", "spanish", "context", "comment"].each do |field|
			if send("#{field}_changed?")
				sanitized_content = sanitize(send(field))
				send("clean_#{field}=", sanitized_content)
			end
		end
	end

	def sanitize(string)
		ActionView::Base.full_sanitizer.sanitize(string.downcase).gsub(/[^\s\w]|_/, "")
	end

	def prevent_domain_orphaning
		Domain.destroy_if_orphaned(domain_id_was) if field_changed?("domain")
	end

	def prevent_source_orphaning
		Source.destroy_if_orphaned(source_id_was) if field_changed?("source")
	end

	def field_changed?(field)
		return true if !persisted?
		self.send("#{field}_id_changed?")
	end
end
