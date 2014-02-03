class TermRecord < ActiveRecord::Base
	attr_accessor :domain_name, :source_name

	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "must be specified" }
	validates :source_id, presence: { message: "must be specified" }

	validate :correct_languages_present

	around_destroy :handle_lookup_orphaning
	around_update :handle_lookup_orphaning

	searchable(includes: [:domains, :sources]) do
		text :english, boost: 5.0
		text :french, boost: 5.0
		text :spanish, boost: 5.0
		text :context, :comment
		text :domain do domain.name end
		text :source do source.name end

		integer :collection_id
		string :context do context.nil? ? nil : scrub_for_sort(context) end
		string :comment do comment.nil? ? nil :  scrub_for_sort(comment) end
		string :english do english.nil? ? nil : scrub_for_sort(english) end
		string :french do french.nil? ? nil : scrub_for_sort(french) end
		string :spanish do spanish.nil? ? nil : scrub_for_sort(spanish) end
		string :domain do scrub_for_sort(domain.name) end
		string :source do scrub_for_sort(source.name) end
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

	def scrub_for_sort(field)
		ActionView::Base.full_sanitizer.sanitize(field.downcase).gsub(/[\W_]/, "")
	end

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
