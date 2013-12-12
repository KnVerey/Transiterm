FactoryGirl.define do
  factory :collection do
    title "Animals"
    description "Fuzzy things on paws"
    english true
    french true
    spanish false
    user
  end

  factory :one_lang_collection, class: Collection do
    title "Animals"
    description "Fuzzy things on paws"
    english true
    french false
    spanish false
    user
  end

  factory :two_lang_collection, class: Collection do
    title "Animals"
    description "Fuzzy things on paws"
    english true
    french false
    spanish true
    user
  end

  factory :three_lang_collection, class: Collection do
    title "Animals"
    description "Fuzzy things on paws"
    english true
    french true
    spanish true
    user
  end

end
