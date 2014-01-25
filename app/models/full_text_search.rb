class FullTextSearch
	attr_reader :collections, :field, :keyword

	def initialize(collections, options = {})
		@collections = collections
		@field = options[:field]
		@keyword = options[:keyword]
	end
end