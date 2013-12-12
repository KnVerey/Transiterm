class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :term_records, dependent: :destroy

	validates :title, presence: true
	validate :valid_num_languages

	def num_languages
		["french","english","spanish"].inject(0) do |counter, lang|
			self.send(lang) ? counter += 1 : counter
		end
	end

	private
	def valid_num_languages
		if !self.french && !self.english && !self.spanish
			errors.add(:base, "Please select at least one language")
		end
	end
end