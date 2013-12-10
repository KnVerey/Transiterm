FactoryGirl.define do
  factory :user do
  	first_name "Katrina"
  	last_name "Verey"
  	email "kn.verey@gmail.com"
  	password "password1"
  	password_confirmation "password1"
  	activation_state "active"
  end
end
