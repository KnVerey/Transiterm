class TermRecord < ActiveRecord::Base
	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "must be specified" }
	validates :source_id, presence: { message: "must be specified" }

	validate :correct_languages_present

	after_destroy :handle_lookup_orphaning
	after_update :handle_lookup_orphaning

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

	private
	def correct_languages_present
		result = Collection::LANGUAGES.detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all language fields") if result
	end

	def handle_lookup_orphaning
		["source", "domain"].each do |field|
			self.send("destroy_#{field}") if (self.send("#{field}_id_changed?") || !self.persisted?) && self.send("#{field}_orphaned?")
		end
	end

	def source_orphaned?
		TermRecord.where(source_id: self.source_id_was).limit(1).empty?
	end

	def domain_orphaned?
		TermRecord.where(domain_id: self.source_id_was).limit(1).empty?
	end

	def destroy_source
		Source.find(self.source_id_was).destroy
	end

	def destroy_domain
		Domain.find(self.domain_id_was).destroy
	end

	# def handle_lookup_orphaning
	# 	destroy_source(self.source_id_was) if (self.source_id_changed? || !self.persisted?) && source_orphaned?(self.source_id_was)
	# 	destroy_domain(self.domain_id_was) if (self.domain_id_changed? || !self.persisted?) && domain_orphaned?(self.domain_id_was)
	# end
end
