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
		expect(empty_search.total_results).to eq(0)
	end

	it "@total_results returns the number of results" do
		expect(search.total_results).to be_an(Integer)
	end

	context "when initializing @field" do
		it "sets the field to nil if 'all' was passed in" do
			expect(min_search.field).to be_nil
		end

		it "sets field to nil if invalid field passed" do
			invalid_search = FactoryGirl.build(:invalid_search)
			expect(invalid_search.field).to be_nil
		end

		it "downcases field name and adds clean_ if valid field passed (test sets directly, not through init)" do
			(Collection::LANGUAGES + ["context", "comment", "source", "domain"]).each do |f|
				search.field = f.upcase
				expect(search.field).to eq("clean_#{f}")
			end
		end
	end

	describe "@results" do
		it "returns a paginated active record relation" do
			c = FactoryGirl.create(:collection)
			t = FactoryGirl.create(:term_record, collection: c)
			s = FactoryGirl.build(:empty_search)
			s.collections = [c.id]

			expect(s.results).to be_an(ActiveRecord::Relation)
			expect(s.results).to respond_to(:current_page)
		end

		it "returns an empty array if no collections set" do
			search.collections = []
			expect(search.results).to eq([])
		end

		it "is paginated, even if empty" do
			search.collections = []
			expect(search.results).to respond_to(:current_page)
		end
	end
end