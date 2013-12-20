class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :term_records, dependent: :destroy

	validates :title, presence: true
	validate :valid_num_languages

  LANGUAGES = %w{english french spanish}
  FIELDS = Collection::LANGUAGES.zip(%w{domain source context comment}).flatten.sort


	def active_languages
		langs = []
		Collection::LANGUAGES.inject(0) do |counter, lang|
			 langs << lang if self.send(lang)
		end
		langs
	end

	def num_languages
		active_languages.length
	end

	private
	def valid_num_languages
		if !self.french && !self.english && !self.spanish
			errors.add(:base, "Please select at least one language")
		end
	end
end