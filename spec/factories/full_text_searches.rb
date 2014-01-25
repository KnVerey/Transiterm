FactoryGirl.define do
	factory :full_text_search do
		ignore do
			collections []
		end

		initialize_with { new([FactoryGirl.create(:collection), FactoryGirl.create(:collection)]) }

		factory :complete_full_text_search do
			initialize_with { new([FactoryGirl.create(:collection), FactoryGirl.create(:collection)], { keywords: "fennec fox", field: "english" }) }
		end
	end
end