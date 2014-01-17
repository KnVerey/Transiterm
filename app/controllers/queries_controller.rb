require 'queries_service.rb'
include QueriesService

class QueriesController < ApplicationController
	def show
		@sidebar_collections = find_collections_by_langs_active

		@selected_collections = filter_collections_by_active_ids(@sidebar_collections)

		@term_records = find_term_record_matches(@selected_collections)
	end
end
