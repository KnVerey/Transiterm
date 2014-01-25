require 'spec_helper'

describe FullTextSearch do

	let(:c) { FactoryGirl.build(:collection) }
	let(:c2) { FactoryGirl.build(:collection) }
	let(:collections) { [c, c2] }
	let(:search) { FactoryGirl.build(:complete_full_text_search) }
	let(:min_search) { FactoryGirl.build(:full_text_search) }

	it "accepts at minimum an array of collections to search and stores this" do
		expect(min_search.collections).to be_an(Array)
	end

	it "accepts a hash with keys keywords and field and stores these" do
		expect(search.keywords).to be_a(String)
	end

	it "accepts a hash with key field and stores this" do
		expect(search.field).to be_a(String)
	end

	describe "#sunspot", solr: true do
		it "sets up a sunspot query" do
			expect(search.sunspot).to be_a(Sunspot::Search::StandardSearch)
		end

		it "generates a query for term records" do
			expect(search.sunspot.inspect).to match(/:fq=>\[\"type:TermRecord\"/)
		end

		it "generates a query with collection ids specified" do
				expect(search.sunspot.inspect).to match(/\"collection_id_i:\(1 OR 2\)\"/)
		end

		context "with no keywords specified" do
			it "generates query with splat" do
				expect(min_search.sunspot.inspect).to match(/:q=>\"*:*\"/)
			end
		end

		context "with keywords specified" do
			it "generates query with keywords" do
				expect(search.sunspot.inspect).to match(/:q=>\"fennec fox\"/)
			end
		end

		context "with no field specified" do
			it "generates query on all fields" do
				expect(min_search.sunspot.inspect).not_to match(/:qf=>/)
			end
		end

		context "with a field specified" do
			it "generates a query on that field" do
				expect(search.sunspot.inspect).to match(/:qf=>\"english_text\"/)
			end
		end
	end

	describe "#sanitize search field" do
		it "exists"
	end

	describe "#results" do
		xit "returns an array of collections" do
			search = FullTextSearch.new(collections, { keywords: "fox", field: "french" })
			expect(search.results).to be_an(Array)
			expect(search.results).not_to be_empty
		end

		it "uses the sunspot query"
	end

end