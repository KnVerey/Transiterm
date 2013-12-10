# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collection do
    name ""
    description ""
    language1_id ""
    language2_id ""
    field1_id ""
    field2_id ""
    sharable false
  end
end
