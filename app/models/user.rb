class User < ActiveRecord::Base
  authenticates_with_sorcery!

  # Require these on create
  validates :password, length: { in: 6..20 }, on: :create
  validates :password, confirmation: true, on: :create
  validates :password_confirmation, on: :create, presence: true
  validates :email, on: :create, presence: true

  # Don't require passwords on update unless one is there
  validates :password, length: { in: 6..20 }, on: :update, if: :password_present?
  validates :password, confirmation: true, on: :update, if: :password_present?
  validates :password_confirmation, on: :update, presence: true, if: :password_present?

  # Always validate the following
  validates :email, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true


  has_many :collections, dependent: :destroy do
    def visible_for_user
      by_active_languages(proxy_association.owner.language_statuses)
    end
  end

  has_many :term_records
  has_many :sources, dependent: :destroy
  has_many :domains, dependent: :destroy

  def language_statuses
    Collection::LANGUAGES.inject({}) do |hash, lang|
       hash[lang.to_sym] = self.send("#{lang}_active")
       hash
    end
  end

  def active_languages
    Collection::LANGUAGES.inject([]) do |active_array, lang|
      self.send("#{lang}_active") ? active_array << lang : active_array
    end
  end

  def active_languages=(to_activate)
    Collection::LANGUAGES.each do |lang|
      state = to_activate.include?(lang)
      self.send("#{lang}_active=", state)
    end
    save
  end

  def toggle_language(language)
    if Collection::LANGUAGES.include?(language)
      self.send("#{language}_active=", !self.send("#{language}_active"))
      save
    end
  end

  private
  def password_present?
    self.password.present? || self.password_confirmation.present?
  end
end
