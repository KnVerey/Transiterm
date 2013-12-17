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
		  expect(@collection.active_languages.kind_of? Array).to be_true
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
		  expect(@collection.active_languages.kind_of? Array).to be_true
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
		  expect(@collection.active_languages.kind_of? Array).to be_true
		  expect(@collection.active_languages.length).to eq(3)
		end

		it "reports the number of languages correctly" do
		  expect(@collection.num_languages).to eq(3)
		end
	end

end
