require 'spec_helper'

describe FullTextSearch do
	let(:search) { FactoryGirl.build(:complete_full_text_search) }
	let(:min_search) { FactoryGirl.build(:full_text_search) }

	it "sets the desired defaults" do
		empty_search = FactoryGirl.build(:empty_search)
		expect(empty_search.collections).to eq([])
		expect(empty_search.field).to be_nil
		expect(empty_search.keywords).to be_nil
		expect(empty_search.page).to eq(1)
	end

	context "when setting the search field" do
		it "downcases the field passed in the initializer" do
			expect(search.field).to eq(search.field.downcase)
		end

		it "downcases valid field names set directly" do
			(Collection::LANGUAGES + Collection::FIELDS).each do |f|
				search.field = f.upcase
				expect(search.field).to eq(f.downcase)
			end
		end

		it "sets field to nil if invalid field passed in initalizer" do
			invalid_search = FactoryGirl.build(:invalid_search)
			expect(invalid_search.field).to be_nil
		end

		it "sets field to nil if invalid field set directly" do
			search.field = "walrus"
			expect(search.field).to be_nil
		end

		it "sets field to nil if 'All' passed in initializer" do
			expect(min_search.field).to be_nil
		end

		it "sets field to nil if 'All' set directly" do
			search.field = "All"
			expect(search.field).to be_nil
		end
	end

	describe "#sunspot", solr: true do
		it "sets up a sunspot query" do
			expect(search.sunspot).to be_a(Sunspot::Search::StandardSearch)
		end

		it "paginates the results" do
			expect(search.sunspot.inspect).to match(/:start=>\d+, :rows=>/)
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

			it "sorts the query results by english by default" do
				expect(search.sunspot.inspect).to match(/:sort=>\"english_s asc\"/)
			end
		end

		context "with a field specified" do
			it "generates a query on that field" do
				expect(search.sunspot.inspect).to match(/:qf=>\"english_text\"/)
			end

			it "narrows by context presence if searching that field" do
				search.field = "context"
				expect(search.sunspot.inspect).to match(/-context_s:\[\* TO \\\"\\\"\]/)
			end

			it "narrows by comment presence if searching that field" do
				search.field = "comment"
				expect(search.sunspot.inspect).to match(/-comment_s:\[\* TO \\\"\\\"\]/)
			end

			it "does not narrow if searching by field other than context/comment" do
				search.field = "spanish"
				expect(search.sunspot.inspect).not_to match(/-\w_s:\[\* TO \\\"\\\"\]/)
			end

			it "sorts the results by the specified field" do
				search.field = "domain"
				expect(search.sunspot.inspect).to match(/:sort=>\"domain_s asc\"/)
			end
		end

		context "with no collections to search" do
			it "never runs a search unfiltered by collection ids" do
				search.collections = []
				expect(search.sunspot.inspect).to match(/collection_id_i:/)
				expect(search.sunspot.inspect).not_to match(/collection_id_i:\[\* TO \*\]/)
			end
		end
	end

	describe "#results", solr: true do
		it "returns an array of collections" do
			expect(search.results).to be_an(Array)
		end

		it "uses the sunspot query" do
			expect(search.results.class).to be(Sunspot::Search::PaginatedCollection)
		end

		it "simply returns an empty array if no collections" do
			search.collections = []
			expect(search.results).to eq([])
		end
	end
end