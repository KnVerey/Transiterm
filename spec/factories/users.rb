FactoryGirl.define do

  factory :user do
  	first_name "Katrina"
  	last_name "Verey"
  	sequence(:email) {|n| "active#{n}@factory.com" }
  	password "password1"
  	password_confirmation "password1"

    factory :active_user do
    	after(:create) { |user| user.activate! }
    end

    factory :locked_user do
      after(:create) { |user| user.send("lock!") }
    end
  end
end
