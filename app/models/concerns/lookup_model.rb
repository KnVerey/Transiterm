module LookupModel
	extend ActiveSupport::Concern

	included do
		after_save :update_duplicate_in_term_records_table
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

	def update_duplicate_in_term_records_table
		if !self.id_changed? && self.name_changed?
			model = self.class.to_s.downcase
			clean_attribute = TermRecord.identify_lookup_duplicate(model)

			term_records.each do |t|
				t.set_lookup_duplicate(attribute: clean_attribute, value: send(self.class.lookup_field))
			end
		end
	end
end