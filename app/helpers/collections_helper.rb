module CollectionsHelper

	def lang_columns
		width = 6 / @collection.num_languages
		columns = { width: width, titles: [] }

		columns[:titles] << "English" if @collection.english
		columns[:titles] << "French" if @collection.french
		columns[:titles] << "Spanish" if @collection.spanish

		return columns
	end
end
