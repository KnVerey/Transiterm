class QueriesController < ApplicationController

	include QueriesService

	def index
		@sidebar_collections = Collection.currently_visible(current_user)

		@selected_collections = Collection.fully_active(current_user)

		@term_records = find_term_record_matches(@selected_collections)
	end
end
