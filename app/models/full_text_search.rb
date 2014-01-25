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
end