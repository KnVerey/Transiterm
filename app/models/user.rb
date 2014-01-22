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

  # Always validate the following
  validates :email, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true


  has_many :collections, dependent: :destroy
  has_many :term_records, through: :collections
  has_many :sources, dependent: :destroy
  has_many :domains, dependent: :destroy


  def active_languages
    langs = []
    Collection::LANGUAGES.each do |lang|
       langs << lang if self.send("#{lang}_active")
    end
    langs
  end

  def toggle_language(language)
    if Collection::LANGUAGES.include?(language)
      self.send("#{language}_active=", !self.send("#{language}_active"))
      save
    end
  end

  def toggle_collection(collection_id_param)
    toggle_me = collection_id_param.to_i
    self.active_collection_ids_will_change!

    if toggle_me == 0 # it was the string passed by the 'all' button
      relevant_ids = find_ids_for_toggle_all
      self.active_collection_ids += relevant_ids
      self.active_collection_ids.uniq!
    elsif self.active_collection_ids.include?(toggle_me)
      self.active_collection_ids.delete(toggle_me)
    else
      self.active_collection_ids.push(toggle_me)
    end

    save
  end

  private
  def password_present?
    self.password.present? || self.password_confirmation.present?
  end

  def find_ids_for_toggle_all
    Collection.select("id").where(
      user_id: self.id,
      french: self.french_active,
      english: self.english_active,
      spanish: self.spanish_active
      ).map { |c| c.id }
  end
end