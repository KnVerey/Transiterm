class User < ActiveRecord::Base
  authenticates_with_sorcery!

  validates :password, length: { in: 6..20 }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true

  validates :email, uniqueness: true
end
