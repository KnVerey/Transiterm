FactoryGirl.define do
	factory :full_text_search do
		ignore do
			collections []
		end

		initialize_with { new(collections: [FactoryGirl.create(:collection), FactoryGirl.create(:collection)], field: "All") }

		factory :complete_full_text_search do
			initialize_with { new(collections: [FactoryGirl.create(:collection), FactoryGirl.create(:collection)], keywords: "fennec fox", field: "english", page: 1) }
		end

		factory :empty_search do
			initialize_with { new() }
		end

		factory :invalid_search do
			initialize_with { new(field: "camel") }
		end
	end
end