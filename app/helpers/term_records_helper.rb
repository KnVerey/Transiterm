module TermRecordsHelper

	def add_or_change_collection_heading
		if @term_record.id.nil?
			"Add to collection"
		else
			"In collection"
		end
	end

	def lang_fields
		@default_collection.active_languages
	end

	def lang_columns(term_record)
		term_record.collection.active_languages
	end

	def source_name
		@term_record.source.try(:name)
	end

	def domain_name
		@term_record.domain.try(:name)
	end

	def current_or_default_collection
		@term_record.collection_id || @default_collection.id
	end
end
