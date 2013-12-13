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
end
