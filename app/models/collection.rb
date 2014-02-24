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

  def toggle
  	self.active = !self.active
  	save
  end

  def self.toggle_all(collections)
  	if collections.any? { |c| c.active == false }
			collections.each(&:activate)
		else
			collections.each(&:deactivate)
		end
  end

  def deactivate
  	self.active = false
  	save
  end

  def activate
  	self.active = true
  	save
  end

	def active_languages
		Collection::LANGUAGES.inject([]) do |active_array, lang|
			 self.send(lang) ? active_array << lang : active_array
		end
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