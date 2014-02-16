class Collection < ActiveRecord::Base
	belongs_to :user
	has_many :term_records, dependent: :destroy

	validates :title, presence: true
	validates :title, length: { in: 1..100 }
	validate :valid_num_languages

  LANGUAGES = %w{english french spanish}
  FIELDS = %w{domain source context comment all}

  default_scope { order(title: :asc) }

  scope :currently_visible, -> (current_user) {
		where(
      user_id: current_user.id,
      french: current_user.french_active,
      english: current_user.english_active,
      spanish: current_user.spanish_active
      )
  }

  scope :fully_active, -> (current_user) {
		currently_visible(current_user).where(
      id: current_user.active_collection_ids
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