require 'spec_helper'

describe FullTextSearch do

	let(:c) { FactoryGirl.build(:collection) }
	let(:c2) { FactoryGirl.build(:collection) }
	let(:collections) { [c, c2] }

	it "accepts and stores an array of collections to search" do
		search = FullTextSearch.new(collections)
		expect(search.collections).to be_an(Array)
	end

	it "accepts a hash with keys keyword and field and stores these" do
		search = FullTextSearch.new(collections, { keyword: "fox", field: "french" })
		expect(search.keyword).to eq("fox")
	end

	it "accepts a hash with key field and stores this" do
		search = FullTextSearch.new(collections, { keyword: "fox", field: "french" })
		expect(search.field).to eq("french")
	end

end