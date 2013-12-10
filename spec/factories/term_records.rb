# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :term_record do
    english "MyString"
    french "MyString"
    spanish "MyString"
    context "MyString"
    comments "MyString"
    domain_id 1
    source_id 1
    collection_id 1
  end
end
