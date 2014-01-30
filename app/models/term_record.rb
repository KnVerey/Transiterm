class TermRecord < ActiveRecord::Base
	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "must be specified" }
	validates :source_id, presence: { message: "must be specified" }

	validate :correct_languages_present

	around_destroy :handle_lookup_orphaning
	around_update :handle_lookup_orphaning

	searchable do
		text :english, boost: 5.0
		text :french, boost: 5.0
		text :spanish, boost: 5.0
		text :context, :comment
		text :domain do domain.name end
		text :source do source.name end

		integer :user_id do collection.user_id end
		integer :collection_id
	end

	def hookup_lookups(lookup_params)
		return false unless self.collection_id

		Domain.transaction do
			self.domain_id = Domain.find_or_create_by(name: lookup_params[:domain_name], user_id: self.collection.user_id).id
			self.source_id = Source.find_or_create_by(name: lookup_params[:source_name], user_id: self.collection.user_id).id
			raise ActiveRecord::Rollback unless self.valid?
		end
	end

	private
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
			potential_orphan.destroy if potential_orphan.term_records.empty?
		end
	end
end
