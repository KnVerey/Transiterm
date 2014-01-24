module QueriesService

	def find_term_record_matches(collections)
		return [] if collections.empty?

		search_field = sanitize_search_field
		sel_collection_ids = collections.map { |c| c.id }

		solr_query = TermRecord.search do
			keywords (params[:search] || "*"), fields: search_field

			all_of do
				with(:collection_id, sel_collection_ids)
			end
		end

		solr_query.results
	end

	private
	def sanitize_search_field
		return nil unless params[:field]

		params[:field].downcase if (Collection::LANGUAGES + Collection::FIELDS).include?(params[:field].downcase) && params[:field] != "All"
	end
end