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

	searchable do
		text :english, boost: 5.0
		text :french, boost: 5.0
		text :spanish, boost: 5.0
		text :context, :comment
		text :domain do domain.name end
		text :source do source.name end

		integer :user_id do collection.user_id end
		integer :collection_id
		string :context do context.nil? ? nil : ActionView::Base.full_sanitizer.sanitize(context.downcase).gsub(/[\W_]/, "") end
		string :comment do comment.nil? ? nil : ActionView::Base.full_sanitizer.sanitize(comment.downcase).gsub(/[\W_]/, "") end
		string :english do english.nil? ? nil : ActionView::Base.full_sanitizer.sanitize(english.downcase).gsub(/[\W_]/, "") end
		string :french do french.nil? ? nil : ActionView::Base.full_sanitizer.sanitize(french.downcase).gsub(/[\W_]/, "") end
		string :spanish do spanish.nil? ? nil : ActionView::Base.full_sanitizer.sanitize(spanish.downcase).gsub(/[\W_]/, "") end
		string :domain do ActionView::Base.full_sanitizer.sanitize(domain.name.downcase).gsub(/[\W_]/, "") end
		string :source do ActionView::Base.full_sanitizer.sanitize(source.name.downcase).gsub(/[\W_]/, "") end
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
