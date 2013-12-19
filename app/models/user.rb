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
  has_many :sources, dependent: :destroy
  has_many :domains, dependent: :destroy


  def toggle_language(language)
    if ["english","french","spanish"].include?(language)
      self.send("#{language}_active", !self.send("#{language}_active"))
    end
  end

  def password_present?
    self.password.present? || self.password_confirmation.present?
  end
end