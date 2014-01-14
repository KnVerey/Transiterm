class QueriesController < ApplicationController

	def show
		@query = Query.new
	end

end
