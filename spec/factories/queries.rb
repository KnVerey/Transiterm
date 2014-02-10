FactoryGirl.define do
	factory :query do
		ignore do
			collections []
		end

		initialize_with { new(collections: [FactoryGirl.create(:collection), FactoryGirl.create(:collection)], field: "All") }

		factory :complete_query do
			initialize_with { new(collections: [FactoryGirl.create(:collection), FactoryGirl.create(:collection)], keywords: "fennec fox", field: "english", page: 1) }
		end

		factory :empty_query do
			initialize_with { new() }
		end

		factory :invalid_query do
			initialize_with { new(field: "camel") }
		end
	end
end