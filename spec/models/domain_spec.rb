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
end
