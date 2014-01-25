class FullTextSearch
	attr_reader :collections, :field, :keywords

	def initialize(collections, options = {})
		@collections = collections
		@field = options[:field]
		@keywords = options[:keywords]
	end

	def results
		[]
	end

	def sunspot
		collection_ids = @collections.map(&:id)
		field = @field
		search_terms = @keywords

		TermRecord.search do
			keywords search_terms, fields: field
			with(:collection_id, collection_ids)
		end
	end
end