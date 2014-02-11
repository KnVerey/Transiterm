FactoryGirl.define do
  factory :term_record do
    english "Hello"
    french "Bonjour"
    spanish "Hola"

    context "Example of usage"
    comment "this is a comment"

    user

    after(:build) do |record|
       record.collection = create(:collection, user: record.user)
       record.domain = create(:domain, user: record.user)
       record.source = create(:source, user: record.user)
    end
  end

end
