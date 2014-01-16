module QueriesHelper
	def set_columns
		current_user.active_languages
	end

	def set_fields
		(current_user.active_languages + Collection::FIELDS).sort.map(&:capitalize)
	end

	def insert_activity_class(collection)
		@selected_collections.include?(collection) ? "active" : "inactive"
	end
end
