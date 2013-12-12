require 'spec_helper'

describe Collection do

	before(:each) do
		User.last.delete
	end

	it 'should not save collections with 0 languages' do
		collection = FactoryGirl.build(:collection, english: false, french: false, spanish: false)

		expect(collection).to be_invalid
	end

	it "should save a collection with one language" do
		collection = FactoryGirl.build(:one_lang_collection)
		expect(collection).to be_valid
	end

	it "should save a collection with two languages" do
		collection = FactoryGirl.build(:two_lang_collection)
		expect(collection).to be_valid
	end

	it "should save a collection with three languages" do
		collection = FactoryGirl.build(:three_lang_collection)
		expect(collection).to be_valid
	end

	describe "reports the number of languages" do
		it "correctly with one language" do
		  collection = FactoryGirl.create(:one_lang_collection)
		  expect(collection.num_languages).to eq(1)
		end

		it "correctly with two languages" do
		  collection = FactoryGirl.create(:two_lang_collection)
		  expect(collection.num_languages).to eq(2)
		end

		it "correctly with one language" do
		  collection = FactoryGirl.create(:three_lang_collection)
		  expect(collection.num_languages).to eq(3)
		end
	end

end
