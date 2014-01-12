FactoryGirl.define do
  factory :collection do
    title "Animals"
    description "Fuzzy things on paws"
    english true
    french true
    spanish false
    user

    factory :one_lang_collection do
      english true
      french false
      spanish false
    end

    factory :two_lang_collection do
      english true
      french false
      spanish true
    end

    factory :three_lang_collection do
      english true
      french true
      spanish true
    end
  end

end
