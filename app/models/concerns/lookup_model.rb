module LookupModel
	extend ActiveSupport::Concern

	module ClassMethods
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
end