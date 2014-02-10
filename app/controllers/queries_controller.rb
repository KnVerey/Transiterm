class QueriesController < ApplicationController

	def show
		@sidebar_collections = Collection.currently_visible(current_user)

		@selected_collections = Collection.fully_active(current_user)

		@query = Query.new(collections: @selected_collections, field: params[:field], keywords: params[:search], page: params[:page])

		@term_records = @query.results
	end
end
