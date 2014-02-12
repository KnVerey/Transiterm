module Searchable
	extend ActiveSupport::Concern

	included do
		before_save :populate_searchable_fields
	end

	module ClassMethods
		def searchable_fields(*fields)
			if fields.present?
				@searchable_fields = fields.map do |f|
					if f.is_a? Hash
						{ field: "clean_#{f[:field]}", attribute: "#{f[:attribute]}"}
					elsif f.is_a? Symbol
						{ field: "clean_#{f}", attribute: "#{f}" }
					end
				end
			end
			@searchable_fields || []
		end
	end

	def populate_searchable_fields
		self.class.searchable_fields.each do |field_hash|
			next unless data_changed?(field_hash[:attribute])
			send("#{field_hash[:field]}=", Searchable.sanitize(field_hash[:attribute]))
		end
	end

	private
	def data_changed?(field)
		return true if !persisted?
		try("#{field}_changed?")
	end

	def self.sanitize(string)
		return unless string
		ActionView::Base.full_sanitizer.sanitize(string.downcase).gsub(/http:\/\/|www\.|[^\p{L}\s\p{N}\-'.]/, "")
	end
end