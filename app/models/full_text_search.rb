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
		query = if @field.include? "source"
			@keywords ? TermRecord.search_by_source(@keywords) : TermRecord.order(updated_at: :desc) #should order by source name
		elsif @field.include? "domain"
			@keywords ? TermRecord.search_by_domain(@keywords) : TermRecord.order(updated_at: :desc) #should order by dom name
		elsif searching_with_keywords_on_another_field?
			TermRecord.search_by_field(@field, @keywords)
		elsif viewing_index_of_another_field?
			TermRecord.where.not(@field => "").order(@field => :asc)
		elsif searching_with_keywords_on_all_fields
			TermRecord.search_whole_record(@keywords)
		else # viewing index for all fields
			TermRecord.order(updated_at: :desc)
		end
		query.where(collection_id: @collections).page(@page)
	end

	def searching_with_keywords_on_another_field?
		@field && @keywords.present?
	end

	def viewing_index_of_another_field?
		@field && @keywords.blank?
	end

	def searching_with_keywords_on_all_fields
		!@field && @keywords.present?
	end

	# def sunspot
	# 	collection_ids = @collections.empty? ? [0] : @collections.map(&:id)
	# 	field = @field
	# 	search_terms = @keywords
	# 	page = @page

	# 	query = Sunspot.search(TermRecord) do
	# 		keywords search_terms, fields: field
	# 		all_of do
	# 			with(:collection_id, collection_ids)
	# 			without(:context, '') if field == "context"
	# 			without(:comment, '') if field == "comment"
	# 		end
	# 		order_by(field || :english, :asc)
	# 		paginate(page: page, per_page: 25)
	# 	end

	# 	@total_results = query.total
	# 	query
	# end

	private
	def sanitize_search_field(field)
		return nil unless field

		if (Collection::LANGUAGES + ["context", "comment"]).include?(field.downcase)
			"clean_#{field.downcase}"
		elsif ["domain", "source"].include?(field.downcase)
			"#{field.downcase}"
		end
	end
end