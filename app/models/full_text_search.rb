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
			# if sorting by context or comment, only show records that have one
			results.select! { |r| r.send(@field).present? } if ["context", "comment"].include?(@field)

			# the sorter gets the field value, downcases, removes html tags and strips markdown
			results.sort_by { |r| ActionView::Base.full_sanitizer.sanitize(field_value(r).downcase).gsub(/\W/, "") }

		else # default sort, i.e. if "All" field selected
			results.sort_by { |r| ActionView::Base.full_sanitizer.sanitize(r.english.downcase).gsub(/\W/, "") }
		end
	end

	def field_value(record) # handles the fact that domain and source names are in lookup table
		field = record.send(@field)
		field.try(:name) ? field.name : field
	end
end