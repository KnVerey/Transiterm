FactoryGirl.define do
	factory :full_text_search do
		ignore do
			collections []
		end

		initialize_with { new(collections) }

		after(:build) do |full_text_search|
			2.times { full_text_search.collections << FactoryGirl.build(:collection) }
		end

		factory :complete_full_text_search do
			initialize_with { new(collections, { keywords: "fennec fox", field: "english" }) }
		end
	end
end