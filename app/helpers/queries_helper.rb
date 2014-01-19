module QueriesHelper
	def set_columns
		current_user.active_languages
	end

	def set_fields
		(current_user.active_languages + Collection::FIELDS).sort.map(&:capitalize)
	end

	def lang_active_class(language)
		"active" if current_user.active_languages.include?(language.downcase)
	end

	def collection_active_class(collection)
		"active" if @selected_collections.include?(collection) && current_user.active_collection_ids.present?
	end

	def all_active_class
		"active" if current_user.active_collection_ids.empty?
	end

	def no_languages_active?
		current_user.active_languages.length == 0
	end

	def any_collections_active?
		@sidebar_collections.present?
	end

	def collection_button_size
		any_collections_active? ? "small-5" : "small-12"
	end

	def pluralized_this_language
		if current_user.active_languages.count == 1
			"this language"
		else
			"these languages"
		end
	end
end
