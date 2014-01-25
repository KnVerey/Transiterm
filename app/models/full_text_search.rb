class FullTextSearch
	attr_reader :collections, :field, :keywords

	def initialize(collections, options = {})
		@collections = collections
		@field = options[:field]
		@keywords = options[:keywords]
	end

	def results
		[]
	end

	def sunspot
		TermRecord.search do
			keywords @keywords, fields: @field
			with(:collection_id, @collections.map(&:id))
		end
	end
end