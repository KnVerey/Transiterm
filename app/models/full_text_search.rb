class FullTextSearch
	attr_accessor :collections, :field, :keywords

	def initialize(collections, options = {})
		@collections = collections
		@field = sanitize_search_field(options[:field])
		@keywords = options[:keywords]
	end

	def results
		if @keywords.present?
			return sunspot.results # sorted by relevance
		else
			results = sunspot.results
			# binding.pry
			sunspot.results.sort_by { |r| r.english.downcase.gsub(/\W/, "") }
		end
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
end