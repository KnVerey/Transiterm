class FullTextSearch
	attr_accessor :collections, :field, :keywords

	def initialize(collections: [], field: nil, keywords: nil, page: 1)
		@collections = collections
		@field = sanitize_search_field(field)
		@keywords = keywords
		@page = page
	end

	def results
		return [] if @collections.empty?
		# leave sorted by relevance if user entered keywords
		# @keywords.present? ? sunspot.results : sort_results(sunspot.results)
		sunspot.results
	end

	def sunspot
		collection_ids = @collections.empty? ? [0] : @collections.map(&:id)
		field = @field
		search_terms = @keywords
		page = @page

		Sunspot.search(TermRecord) do
			keywords search_terms, fields: field
			all_of do
				with(:collection_id, collection_ids)
				without(:context, '') if field == "context"
				without(:comment, '') if field == "comment"
			end
			paginate(page: page, per_page: 5)
		end
	end

	private
	def sanitize_search_field(field)
		return nil unless field

		field.downcase if (Collection::LANGUAGES + Collection::FIELDS).include?(field.downcase) && field != "All"
	end

	def sort_results(results)
		# sort block gets the field value, downcases, removes html tags and strips markdown
		results.sort_by! { |r| ActionView::Base.full_sanitizer.sanitize(field_value(r).downcase).gsub(/[\W_]/, "") }
	end

	def field_value(record) # handles lookups and default field
		value = record.send(@field || "english")
		value.try(:name) || value
	end
end