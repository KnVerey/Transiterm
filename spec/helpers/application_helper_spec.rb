require 'spec_helper'

describe ApplicationHelper do
	let(:person) { FactoryGirl.create(:user) }
	before(:each) { helper.stub(:current_user).and_return(person) }

	describe "#format_active_langs" do
		it "returns a string" do
		  expect(helper.format_active_langs).to be_a(String)
		end
	end
end