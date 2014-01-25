class FullTextSearch
	attr_reader :collections, :field, :keywords

	def initialize(collections, options = {})
		@collections = collections
		@field = options[:field]
		@keywords = options[:keywords]
	end

	def results
		self.send(:sunspot).try(:results) || []
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

	# private
	# def sanitize_search_field
	# 	return nil unless params[:field]

	# 	params[:field].downcase if (Collection::LANGUAGES + Collection::FIELDS).include?(params[:field].downcase) && params[:field] != "All"
	# end
end