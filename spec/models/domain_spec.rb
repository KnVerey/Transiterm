require 'spec_helper'

describe Domain do
	it "must not save if empty" do
		dom = FactoryGirl.build(:domain, name: "")
		expect(dom).to be_invalid
	end

	it "belongs to a user" do
		dom = Domain.new(name: "Medical")
		expect(dom).to be_invalid
	end

	context "before save" do
		it "populates the clean name field if it was nil" do
			domain = FactoryGirl.build(:domain)
			domain.save
			expect(domain.clean_name).not_to be_nil
		end

		it "updates the clean name field if it was not nil" do
			domain = FactoryGirl.create(:domain)
			domain.name = "Changed"
			domain.save
			expect(domain.clean_name).to eq("changed")
		end
	end
end
