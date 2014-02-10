module Searchable
	extend ActiveSupport::Concern

	def searchable_fields
		attributes.select{ |k,v| k.include? "clean_"}
	end

	def populate_searchable_fields
		searchable_fields.each_key do |clean_field_name|
			clean_data = sanitize(get_original_data(clean_field_name))
			send("#{clean_field_name}=", clean_data)
		end
	end

	private

	def get_original_data(clean_field_name)
		unclean = clean_field_name.gsub("clean_", "")
		attributes[unclean] || send("#{unclean}_name")
	end

	def sanitize(string)
		ActionView::Base.full_sanitizer.sanitize(string.downcase).gsub(/[^\s\w]|_/, "")
	end
end