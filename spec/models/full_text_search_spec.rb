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

	it "sanitizes the search field" do
		expect(search).to receive(:sanitize_search_field)
		search.send(:initialize, collections)
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
		it "returns nil if no field specified" do
			expect(min_search.send(:sanitize_search_field, nil)).to be_nil
		end

		it "returns downcase name if valid field" do
			(Collection::LANGUAGES + Collection::FIELDS).each do |f|
				expect(search.send(:sanitize_search_field, f)).to eq(f.downcase)
			end
		end

		it "returns nil if invalid field specified" do
			expect(search.send(:sanitize_search_field, "jibberish")).to be_nil
		end

		it "returns nil if All field specified" do
			expect(search.send(:sanitize_search_field, "All")).to be_nil
		end

	end

	describe "#results", solr: true do

		#this test doesn't really work... solr query in test env never returning results
		it "returns empty array if no collections to search" do
			search.collections = []
			expect(search.results).to eq([])
		end

		it "returns an array of collections" do
			expect(search.results).to be_an(Array)
		end

		it "uses the sunspot query" do
			# This happens inside the sunspot method, which the test refuses to call if I set an expectation straight on search
			expect(search.collections).to receive(:map)
			search.results
		end
	end

	# testing separate from public interface b/c sunspot doesn't properly return results in test env
	describe "#sort_results" do
		let(:r1) { FactoryGirl.build(:term_record, english: "bb", french: "aa", spanish: "bb" ) }
		let(:r2) { FactoryGirl.build(:term_record, english: "cc", french: "cc", spanish: "aa" ) }
		let(:r3) { FactoryGirl.build(:term_record, english: "aa", french: "bb", spanish: "cc" ) }

		it "sorts alphabetically by english if no field selected" do
			search.field = nil
			expect(search.send("sort_results",[r1, r2, r3]).first).to eq(r3)
			expect(search.send("sort_results",[r1, r2, r3]).last).to eq(r2)
		end

		it "sorts alphabetically by french if selected" do
			search.field = "french"
			expect(search.send("sort_results",[r1, r2, r3]).first).to eq(r1)
			expect(search.send("sort_results",[r1, r2, r3]).last).to eq(r2)
		end

		it "sorts alphabetically by spanish if selected" do
			search.field = "spanish"
			expect(search.send("sort_results",[r1, r2, r3]).first).to eq(r2)
			expect(search.send("sort_results",[r1, r2, r3]).last).to eq(r3)
		end

		it "sorts alphabetically by source if selected" do
			r1.source.name = "cc"
			r2.source.name = "bb"
			r3.source.name = "aa"
			search.field = "source"

			expect(search.send("sort_results",[r1, r2, r3]).first).to eq(r3)
			expect(search.send("sort_results",[r1, r2, r3]).last).to eq(r1)
		end

		it "sorts alphabetically by domain if selected" do
			r1.domain.name = "ab"
			r2.domain.name = "bc"
			r3.domain.name = "cd"
			search.field = "domain"

			expect(search.send("sort_results",[r2, r1, r3]).first).to eq(r1)
			expect(search.send("sort_results",[r2, r1, r3]).last).to eq(r3)
		end

		it "sorts alphabetically by comment if selected" do
			r1.comment = "ab"
			r2.comment = "bc"
			r3.comment = "cd"
			search.field = "comment"

			expect(search.send("sort_results",[r2, r1, r3]).first).to eq(r1)
			expect(search.send("sort_results",[r2, r1, r3]).last).to eq(r3)
		end

		it "sorts alphabetically by context if selected" do
			r1.context = "ab"
			r2.context = "bc"
			r3.context = "cd"
			search.field = "context"

			expect(search.send("sort_results",[r2, r1, r3]).first).to eq(r1)
			expect(search.send("sort_results",[r2, r1, r3]).last).to eq(r3)
		end

		it "is case insensitive" do
			r1.english = "Pear"
			r2.english = "public"
			r3.english = "pat"

			expect(search.send("sort_results",[r2, r1, r3]).first).to eq(r3)
			expect(search.send("sort_results",[r2, r1, r3]).last).to eq(r2)
		end

		it "is not derailed by html tags" do
			r1.english = "<strong>Pear</strong>"
			r2.english = "public"
			r3.english = "pat"

			expect(search.send("sort_results",[r2, r1, r3]).first).to eq(r3)
			expect(search.send("sort_results",[r2, r1, r3]).last).to eq(r2)
		end

		it "is not derailed by markdown" do
			r1.english = "**Pear**"
			r2.english = "_public_"
			r3.english = "pat"

			expect(search.send("sort_results",[r2, r1, r3]).first).to eq(r3)
			expect(search.send("sort_results",[r2, r1, r3]).last).to eq(r2)
		end

		it "strips out commentless records if @field is comments" do
			r1.comment = "type of bird"
			r2.comment = ""
			r3.comment = ""
			search.field = "comment"

			expect(search.send("sort_results",[r2, r1, r3]).length).to eq(1)
		end

		it "strips out contextless records if @field is context" do
			r1.context = "example"
			r2.context = ""
			r3.context = "another example"
			search.field = "context"

			expect(search.send("sort_results",[r2, r1, r3]).length).to eq(2)
		end
	end

end