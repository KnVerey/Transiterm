class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :term_records, dependent: :destroy

	validates :title, presence: true
	validates :title, length: { in: 1..100 }
	validate :valid_num_languages

  LANGUAGES = %w{english french spanish}
  FIELDS = %w{domain source context comment all}

  default_scope { order(title: :asc) }

  scope :by_active_languages, -> (status_hash) {
		where(
      status_hash.slice(:french, :english, :spanish)
      )
  }

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