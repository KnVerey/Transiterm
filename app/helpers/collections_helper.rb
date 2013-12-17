module CollectionsHelper

	def lang_columns(collection = @collection)
		columns = { titles: [] }

		columns[:titles] << "English" if collection.english
		columns[:titles] << "French" if collection.french
		columns[:titles] << "Spanish" if collection.spanish

		return columns
	end
end
