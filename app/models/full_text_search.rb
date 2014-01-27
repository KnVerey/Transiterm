class FullTextSearch
	attr_accessor :collections, :field, :keywords

	def initialize(collections, options = {})
		@collections = collections
		@field = sanitize_search_field(options[:field])
		@keywords = options[:keywords]
	end

	def results
		# leave sorted by relevance if user entered keywords
		@keywords.present? ? sunspot.results : sort_results(sunspot.results)
	end

	def sunspot
		collection_ids = @collections.map(&:id)
		field = @field
		search_terms = @keywords

		Sunspot.search(TermRecord) do
			keywords search_terms, fields: field
			with(:collection_id, collection_ids)
		end
	end

	private
	def sanitize_search_field(field)
		return nil unless field

		field.downcase if (Collection::LANGUAGES + Collection::FIELDS).include?(field.downcase) && field != "All"
	end

	def sort_results(results)
		if @field.present?
			results.sort_by { |r| field_value(r).downcase.gsub(/\W/, "") }

		else # i.e. default sort if "All" field selected
			results.sort_by { |r| r.english.downcase.gsub(/\W/, "") }
		end
	end

	def field_value(record) #because domain and source names are in lookup table
		field = record.send(@field)
		field.try(:name) ? field.name : field
	end
end