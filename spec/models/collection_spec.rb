require 'spec_helper'

describe Collection do

	context "with no languages" do
		it 'should not save the collection' do
			collection = FactoryGirl.build(:collection, english: false, french: false, spanish: false)

			expect(collection).to be_invalid
		end
	end

	context "with one language" do
		before(:all) { @collection = FactoryGirl.build(:one_lang_collection) }

		it "saves the collection" do
 			expect(@collection).to be_valid
		end

		it "reports an array of one language name" do
		  expect(@collection.active_languages.kind_of? Array).to be true
		  expect(@collection.active_languages.length).to eq(1)
		end

		it "reports the number of languages correctly" do
		  expect(@collection.num_languages).to eq(1)
		end
	end

	context "with two languages" do
		before(:all) { @collection = FactoryGirl.build(:two_lang_collection) }
		it "saves the collection" do
			expect(@collection).to be_valid
		end

		it "reports an array of two language names" do
		  expect(@collection.active_languages.kind_of? Array).to be true
		  expect(@collection.active_languages.length).to eq(2)
		end

		it "reports the number of languages correctly" do
		  expect(@collection.num_languages).to eq(2)
		end

	end

	context "with three languages" do
		before(:all) { @collection = FactoryGirl.build(:three_lang_collection) }

		it "saves the collection" do
			expect(@collection).to be_valid
		end

		it "reports an array of three language names" do
		  expect(@collection.active_languages.kind_of? Array).to be true
		  expect(@collection.active_languages.length).to eq(3)
		end

		it "reports the number of languages correctly" do
		  expect(@collection.num_languages).to eq(3)
		end
	end

	describe "#toggle" do
		it "inverts the activity attribute of the collection (persisted)" do
		  c = FactoryGirl.create(:three_lang_collection, active: true)
		  c.toggle
		  c.reload
		  expect(c.active).to be false
		  c.toggle
		  c.reload
		  expect(c.active).to be true
		end
	end

	describe "self.toggle_all" do
		context "when at least one collection is inactive" do
			it "activates all collections passed in" do
			  c = FactoryGirl.create(:three_lang_collection, active: false)
			  c2 = FactoryGirl.create(:three_lang_collection, active: true)
			  c3 = FactoryGirl.create(:three_lang_collection, active: true)

			  Collection.toggle_all([c, c2, c3])

			  all_active = [c, c2, c3].all? { |x| x.active }
			  expect(all_active).to be true
			end
		end

		context "when all collections are already active" do
			it "deactivates all the collections passed in" do
			  c = FactoryGirl.create(:three_lang_collection, active: true)
			  c2 = FactoryGirl.create(:three_lang_collection, active: true)
			  c3 = FactoryGirl.create(:three_lang_collection, active: true)

			  Collection.toggle_all([c, c2, c3])

			  any_active = [c, c2, c3].any? { |x| x.active }
			  expect(any_active).to be false
			end
		end
	end

	describe "#activate" do
		it "sets collection active to true (persisted)" do
		  c = FactoryGirl.create(:three_lang_collection, active: false)
		  c.activate
		  c.reload
		  expect(c.active).to be true
		  c.activate
		  c.reload
		  expect(c.active).to be true
		end
	end

	describe "#deactivate" do
		it "sets collection active to false (persisted)" do
		  c = FactoryGirl.create(:three_lang_collection, active: true)
		  c.deactivate
		  c.reload
		  expect(c.active).to be false
		  c.deactivate
		  c.reload
		  expect(c.active).to be false
		end
	end
end
