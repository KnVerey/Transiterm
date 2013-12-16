class TermRecord < ActiveRecord::Base
	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "Please specify a domain" }
	validates :source_id, presence: { message: "Please specify a source" }

	validate :correct_languages_present

	private
	def correct_languages_present
		result = ["french","english","spanish"].detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all langauge fields") if result
	end
end
