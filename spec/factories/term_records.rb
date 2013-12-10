# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :term_record do
    english "Hello"
    french "Bonjour"
    spanish "Hola"

    context "Example of usage"
    comment "this is a comment"

    domain
    source
    collection
  end
end
