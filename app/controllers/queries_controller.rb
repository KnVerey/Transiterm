class QueriesController < ApplicationController

	def index
		@sidebar_collections = Collection.currently_visible(current_user)

		@selected_collections = Collection.fully_active(current_user)

		@term_records = FullTextSearch.new(collections: @selected_collections, field: params[:field], keywords: params[:search], page: params[:page]).results
	end
end
