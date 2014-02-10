module Searchable
	extend ActiveSupport::Concern

	included do
		before_save :populate_searchable_fields
	end

	def searchable_fields
		attributes.select{ |k,v| k.include? "clean_"}
	end

	def populate_searchable_fields
		searchable_fields.each_key do |clean_field_name|
			data_field = get_data_field_name(clean_field_name)
			next unless field_changed?(data_field)

			clean_data = sanitize(send(data_field))
			send("#{clean_field_name}=", clean_data)
		end
	end

	private
	def field_changed?(field)
		return true if !persisted?

		field = field.gsub("_name","_id") if field.include?("_name")
		try("#{field}_changed?")
	end

	def get_data_field_name(clean_field_name)
		name_if_core = clean_field_name.gsub("clean_", "")
		attributes.has_key?(name_if_core) ? name_if_core : "#{name_if_core}_name"
	end

	def sanitize(string)
		return nil unless string
		ActionView::Base.full_sanitizer.sanitize(string.downcase).gsub(/[^\s\w]|_/, "")
	end
end