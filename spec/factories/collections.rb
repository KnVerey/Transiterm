# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection do
    title "Animals"
    description "Fuzzy things on paws"
    english true
    french true
    spanish false
    user
  end
end
