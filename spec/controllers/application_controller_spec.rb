require 'spec_helper'

describe ApplicationController do
	describe "user_is_owner?" do
		context "when passed a collection" do
			it "returns true if the collection belongs to current_user" do
				person = FactoryGirl.build(:user)
				person_collection = FactoryGirl.build(:collection, user: person)
				controller.stub(:current_user).and_return(person)

				expect(controller.send("user_is_owner?", person_collection)).to eq(true)
			end

			it "returns false if the collection belongs to someone else" do
				person = FactoryGirl.build(:user)
				collection = FactoryGirl.build(:collection)
				controller.stub(:current_user).and_return(person)

				expect(controller.send("user_is_owner?", collection)).to eq(false)
			end
		end

		context "when passed a term record" do
			it "returns true if the term record belongs to current_user" do
				person = FactoryGirl.build(:user)
				person_collection = FactoryGirl.build(:collection, user: person)
				record = FactoryGirl.build(:term_record, collection: person_collection)
				controller.stub(:current_user).and_return(person)

				expect(controller.send("user_is_owner?", record)).to eq(true)
			end

			it "returns false if the term record belongs to someone else" do
				person = FactoryGirl.build(:user)
				collection = FactoryGirl.build(:collection)
				record = FactoryGirl.build(:term_record, collection: collection)
				controller.stub(:current_user).and_return(person)

				expect(controller.send("user_is_owner?", record)).to eq(false)
			end
		end
	end
end