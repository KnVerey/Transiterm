require 'spec_helper'

describe Source do
	it "must not save if empty" do
		source = FactoryGirl.build(:source, name: "")
		expect(source).to be_invalid
	end

	it "belongs to a user" do
		source = Source.new(name: "Medical")
		expect(source).to be_invalid
	end

	context "before save" do
		it "populates the clean name field if it was nil" do
			source = FactoryGirl.build(:source)
			source.save
			expect(source.clean_name).not_to be_nil
		end

		it "updates the clean name field if it was not nil" do
			source = FactoryGirl.create(:source)
			source.name = "Changed"
			source.save
			expect(source.clean_name).to eq("changed")
		end
	end
end
