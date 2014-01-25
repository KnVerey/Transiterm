require 'spec_helper'

describe FullTextSearch do

	let(:c) { FactoryGirl.build(:collection) }
	let(:c2) { FactoryGirl.build(:collection) }
	let(:collections) { [c, c2] }
	let(:search) { FactoryGirl.build(:full_text_search) }

	it "accepts at minimum an array of collections to search and stores this" do
		expect(search.collections).to be_an(Array)
	end

	it "accepts a hash with keys keywords and field and stores these" do
		search = FullTextSearch.new(collections, { keywords: "fox", field: "french" })
		expect(search.keywords).to eq("fox")
	end

	it "accepts a hash with key field and stores this" do
		search = FullTextSearch.new(collections, { keywords: "fox", field: "french" })
		expect(search.field).to eq("french")
	end

	describe "#sunspot" do
		it "sets up a sunspot query" do

		end

		context "with no keywords specified" do
			it "generates query with splat"
		end

		context "with keywords specified" do
			it "generates query with keywords"
		end

		context "with no field specified" do
			it "generates query on all fields"
		end

		context "with a field specified" do
			it "generates a query on that field"
		end
	end

	describe "#results" do
		xit "returns an array of collections" do
			search = FullTextSearch.new(collections, { keywords: "fox", field: "french" })
			expect(search.results).to be_an(Array)
			expect(search.results).not_to be_empty
		end
	end

end