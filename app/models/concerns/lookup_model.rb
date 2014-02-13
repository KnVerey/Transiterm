module LookupModel
	extend ActiveSupport::Concern

	included do
		after_save :update_name_in_term_records_table
	end

	module ClassMethods
		def lookup_field(*field)
			@lookup_field = field.first if field.present?
			@lookup_field
		end

		def destroy_if_orphaned(id)
			source = self.find(id)
			source.destroy if source.orphaned?
		end

		def orphans
			self.all.select { |r| r.term_records.empty? }
		end
	end

	def orphaned?
		term_records.empty?
	end

	def update_name_in_term_records_table
		if !self.id_changed? && self.name_changed?
			model = self.class.to_s.downcase
			clean_attribute = TermRecord.searchable_fields.find { |field_hash| field_hash[:attribute].match(/#{model}/) }[:field]

			term_records.each do |t|
				clean_data = Searchable.sanitize(send(self.class.lookup_field))
				t.send("#{clean_attribute}=", clean_data)
				t.save
			end
		end
	end
end