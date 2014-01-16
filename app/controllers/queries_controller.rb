class QueriesController < ApplicationController

	def show
		@sidebar_collections = find_collections_for_sidebar

		@selected_collections = find_collections_for_search
		@term_records = find_term_record_matches
	end


	private

	def find_collections_for_sidebar
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

	def find_collections_for_search
		if current_user.active_collection_ids.empty?
			@sidebar_collections
		else
			@sidebar_collections.select do |collection|
				current_user.active_collection_ids.include?(collection.id)
			end
		end

	end

	def sanitize_search_field
		((Collection::LANGUAGES + Collection::FIELDS).include?(params[:field]) && params[:field] != "All") ? params[:field].downcase : nil
	end

	def find_term_record_matches
		return [] if @selected_collections.empty?

		search_field = sanitize_search_field
		sel_collection_ids = @selected_collections.map { |c| c.id }

		solr_query = TermRecord.search do
			keywords (params[:search] || "*"), fields: search_field

			all_of do
				with(:collection_id, sel_collection_ids)
			end
		end

		solr_query.results
	end

end
