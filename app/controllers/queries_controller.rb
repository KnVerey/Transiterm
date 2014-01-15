class QueriesController < ApplicationController

	def show
		@fields = set_fields
		@columns = set_columns
		@query = configure_new_query

		@query.run
	end


	private
	def configure_new_query
		user_id = current_user.id
		languages = current_user.active_languages
		collection_ids = current_user.active_collection_ids
		search_field = sanitize_search_field
		keywords = params[:search]

		Query.new(user_id, languages, collection_ids, search_field, keywords)
	end

	def set_columns
		@columns = current_user.active_languages
	end

	def set_fields
		@fields = (current_user.active_languages + Collection::FIELDS).sort.map(&:capitalize)
	end

	def sanitize_search_field
		(@fields.include?(params[:field]) && params[:field] != "All") ? params[:field].downcase : nil
	end

end
