FactoryGirl.define do

  sequence :email do |n|
    "email#{n + rand(10000)}@test.com"
  end

  factory :user do
  	first_name "Katrina"
  	last_name "Verey"
  	email
  	password "password1"
  	password_confirmation "password1"
  	after(:create) { |user| user.activate! }
  end

  factory :inactive_user, class: User do
  	first_name "Kate"
  	last_name "Smith"
    email
  	password "password1"
  	password_confirmation "password1"
  end

  factory :locked_user, class: User do
    first_name "Jane"
    last_name "Miller"
    email
    password "password1"
    password_confirmation "password1"
    after(:create) { |user| user.send("lock!") }
  end
end
