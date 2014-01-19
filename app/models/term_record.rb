class TermRecord < ActiveRecord::Base
	belongs_to :collection, touch: true
	belongs_to :domain
	belongs_to :source

	validates :domain_id, presence: { message: "must be specified" }
	validates :source_id, presence: { message: "must be specified" }

	validate :correct_languages_present

	searchable do
		text :english, boost: 5.0
		text :french, boost: 5.0
		text :spanish, boost: 5.0
		text :context, :comment
		text :domain do domain.name end
		text :source do source.name end

		integer :user_id do collection.user_id end
		integer :collection_id
	end

	private
	def correct_languages_present
		result = Collection::LANGUAGES.detect do |language|
			self.collection.send(language) && self.send(language).empty?
		end

		errors.add(:base, "Please fill in all language fields") if result
	end
end
