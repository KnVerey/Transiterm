class TermRecord < ActiveRecord::Base
	include PgSearch
	include Searchable
	searchable_fields :english, :french, :spanish, :context, :comment, :source, :domain
	# { field: :domain, attribute: :domain_name }

	pg_search_scope :search_whole_record,
		against: {
			clean_english: 'A',
			clean_french: 'A',
			clean_spanish: 'A',
			clean_context: 'B',
			clean_comment: 'B',
			clean_source: 'C',
			clean_domain: 'C'
		},
		using: { tsearch: {:prefix => true} },
		ignoring: :accents,
		order_within_rank: "term_records.updated_at DESC"

	pg_search_scope :search_by_field,
		lambda { |field, query|
			{
				against: field,
				query: query,
				using: { tsearch: {:prefix => true} },
				ignoring: :accents,
				order_within_rank: "term_records.updated_at DESC"
			}
		}

	attr_accessor :domain_name, :source_name

	belongs_to :user
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
	after_destroy :prevent_lookup_orphaning
	after_update :prevent_lookup_orphaning

	def domain_name
		@domain_name || domain.try(:name)
	end

	def source_name
		@source_name || source.try(:name)
	end

	private
	def assign_domain
		self.domain = Domain.find_or_initialize_by(user: user, name: domain_name)
	end

	def assign_source
		self.source = Source.find_or_initialize_by(user: user, name: source_name)
	end

	def correct_languages_present
		result = Collection::LANGUAGES.detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all language fields") if result
	end

	def prevent_lookup_orphaning
		["source", "domain"].each do |l_field|
			old_id = send("#{l_field.downcase}_id_was")
			l_field.capitalize.constantize.destroy_if_orphaned(old_id) if send("#{l_field}_id_changed?") || !persisted?
		end
	end
end
