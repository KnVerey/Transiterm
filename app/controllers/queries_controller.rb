class QueriesController < ApplicationController
	respond_to :html, :js

	def show
		@sidebar_collections = current_user.collections.visible_for_user.load

		@selected_collections = @sidebar_collections.select(&:active)

		@query = Query.new(collections: @selected_collections, field: params[:field], keywords: params[:search], page: params[:page])

		@term_records = @query.results
	end
end
