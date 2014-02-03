class FullTextSearch
	attr_accessor :collections, :keywords, :page
	attr_reader :field, :total_results

	def initialize(collections: [], field: nil, keywords: nil, page: 1)
		@collections = collections
		@field = sanitize_search_field(field)
		@keywords = keywords
		@page = page
		@total_results = 0
	end

	def field=(field)
		@field = sanitize_search_field(field)
	end

	def results
		return [] if @collections.empty?
		sunspot.results
	end

	def sunspot
		collection_ids = @collections.empty? ? [0] : @collections.map(&:id)
		field = @field
		search_terms = @keywords
		page = @page

		query = Sunspot.search(TermRecord) do
			keywords search_terms, fields: field
			all_of do
				with(:collection_id, collection_ids)
				without(:context, '') if field == "context"
				without(:comment, '') if field == "comment"
			end
			order_by(field || :english, :asc)
			paginate(page: page, per_page: 25)
		end

		@total_results = query.total
		query
	end

	private
	def sanitize_search_field(field)
		return nil unless field

		field.downcase if (Collection::LANGUAGES + Collection::FIELDS).include?(field.downcase) && field != "All"
	end
end