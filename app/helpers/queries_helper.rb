module QueriesHelper

	def title_for_print
		"<p class='subheader'><strong>Collections</strong>: #{format_collection_titles}</p>
		<p class='subheader'><strong>Filter</strong>: #{keywords_and_field}</p>".html_safe
	end

	def keywords_and_field
		if @query.keywords.present?
			field = @query.field.present? ? " in #{@query.field.gsub("clean_", "").capitalize}" : " in any field"
			"\"#{@query.keywords}\"#{field}"
		else
			"none"
		end
	end

	def format_collection_titles
		@selected_collections.map {|c| c.title }.join(", ")
	end

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
		"active" if @selected_collections.include?(collection)
	end

	def all_active_class
		"active" if all_displayed_active?
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

	def all_displayed_active?
		all_ids = @sidebar_collections.map { |c| c.id }.sort
		selected_ids = @selected_collections.map { |c| c.id }.sort
		all_ids == selected_ids
	end

	def collection_result_count
		num_results = @query.total_results
		num_collections = @selected_collections.length

		"#{num_collections} #{format_active_langs} #{'collection'.pluralize(num_collections)} (#{num_results} #{'result'.pluralize(num_results)})"
	end
end
