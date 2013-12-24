class TermRecord < ActiveRecord::Base
	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "Please specify a domain" }
	validates :source_id, presence: { message: "Please specify a source" }

	validate :correct_languages_present

	searchable do
		text :english, :french, :spanish, :context, :comment
		text :domain { domain.name }
		text :source { source.name }

		integer :category_id
	end

	private
	def correct_languages_present
		result = Collection::LANGUAGES.detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all langauge fields") if result
	end
end
