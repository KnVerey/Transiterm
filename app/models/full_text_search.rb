class FullTextSearch
	attr_accessor :collections, :field, :keywords

	def initialize(collections, options = {})
		@collections = collections
		@field = sanitize_search_field(options[:field])
		@keywords = options[:keywords]
	end

	def results
		return [] if @collections.empty?
		# leave sorted by relevance if user entered keywords
		@keywords.present? ? sunspot.results : sort_results(sunspot.results)
	end

	def sunspot
		collection_ids = @collections.empty? ? [0] : @collections.map(&:id)
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
		# if sorting by context or comment, only show records that have one
		results.select! { |r| r.send(@field).present? } if ["context", "comment"].include?(@field) if @field.present?

		# sort block gets the field value, downcases, removes html tags and strips markdown
		results.sort_by { |r| ActionView::Base.full_sanitizer.sanitize(field_value(r).downcase).gsub(/[\W_]/, "") }
	end

	def field_value(record) # handles lookups and default field
		value = record.send(@field || "english")
		value.try(:name) || value
	end
end