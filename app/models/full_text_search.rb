class FullTextSearch
	attr_accessor :collections, :keywords, :page
	attr_reader :field, :total_results, :results
	def field=(field)
		@field = sanitize_search_field(field)
	end

	def initialize(collections: [], field: nil, keywords: nil, page: 1)
		@collections = collections
		@field = sanitize_search_field(field)
		@keywords = keywords
		@page = page
		@total_results = get_results.count
		@results = get_results.page(@page)
	end

	private
	def get_results
		if searching_with_keywords?
			TermRecord.search_by_field(@field, @keywords)
		elsif viewing_index_for_specific_field?
			TermRecord.where.not(@field => "").order(@field => :asc)
		elsif searching_with_keywords_on_all_fields
			TermRecord.search_whole_record(@keywords)
		else # viewing index for all fields
			TermRecord.order(updated_at: :desc)
		end.where(collection_id: @collections)
	end

	def searching_with_keywords?
		@field && @keywords.present?
	end

	def viewing_index_for_specific_field?
		@field && @keywords.blank?
	end

	def searching_with_keywords_on_all_fields
		!@field && @keywords.present?
	end

	def sanitize_search_field(field)
		return nil unless field

		"clean_#{field.downcase}" if (Collection::LANGUAGES + Collection::FIELDS).include?(field.downcase) && field.downcase != "all"
	end
end