class TermRecord < ActiveRecord::Base
	include PgSearch

	attr_accessor :domain_name, :source_name

	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "must be specified" }
	validates :source_id, presence: { message: "must be specified" }

	validate :correct_languages_present

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

	def hookup_lookups(lookup_params)
		return false unless self.collection_id

		Domain.transaction do
			self.domain_id = Domain.find_or_create_by(name: lookup_params[:domain_name], user_id: self.collection.user_id).id if lookup_params[:domain_name]
			self.source_id = Source.find_or_create_by(name: lookup_params[:source_name], user_id: self.collection.user_id).id if lookup_params[:source_name]
			raise ActiveRecord::Rollback unless self.valid?
		end

		set_virtual_attributes(lookup_params) if !lookups_hookedup?
		return lookups_hookedup?
	end

	private
	def lookups_hookedup?
		self.domain_id && self.source_id
	end
	def set_virtual_attributes(lookup_params)
		self.domain_name = lookup_params[:domain_name]
		self.source_name = lookup_params[:source_name]
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
