class QueriesController < ApplicationController

	include QueriesService

	def index
		@sidebar_collections = Collection.find_by_user_active_langs(current_user)

		@selected_collections = filter_collections_by_active_ids(@sidebar_collections)

		@term_records = find_term_record_matches(@selected_collections)
	end
end
