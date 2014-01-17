module QueriesService

	def find_collections_by_langs_active
		return [] if current_user.collections.count == 0

		solr_query = Collection.search do
			all_of do
				with(:user_id, current_user.id)
				with(:french, current_user.french_active)
				with(:english, current_user.english_active)
				with(:spanish, current_user.spanish_active)
			end
		end
		solr_query.results
	end

	def filter_collections_by_active_ids(collection_set)
		if no_active_ids?
			collection_set
		else
			collection_set.select do |collection|
				current_user.active_collection_ids.include?(collection.id)
			end
		end
	end

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
	def no_active_ids?
		current_user.active_collection_ids.empty?
	end

	def sanitize_search_field
		return nil unless params[:field]

		params[:field].downcase if (Collection::LANGUAGES + Collection::FIELDS).include?(params[:field].downcase) && params[:field] != "All"
	end
end