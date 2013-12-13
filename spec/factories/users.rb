FactoryGirl.define do
  factory :user do
  	first_name "Katrina"
  	last_name "Verey"
  	email { "test#{rand(1000)}@test.com" }
  	password "password1"
  	password_confirmation "password1"
  	after(:create) { |user| user.activate! }
  end

  factory :inactive_user, class: User do
  	first_name "Kate"
  	last_name "Smith"
    email { "test#{rand(1000)}@test.com" }
  	password "password1"
  	password_confirmation "password1"
  end

  factory :locked_user, class: User do
    first_name "Jane"
    last_name "Miller"
    email { "test#{rand(1000)}@test.com" }
    password "password1"
    password_confirmation "password1"
    after(:create) { |user| user.send("lock!") }
  end
end
