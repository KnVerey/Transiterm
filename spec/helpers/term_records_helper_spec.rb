require 'spec_helper'

describe TermRecordsHelper do

	describe "#add_or_change_collection_heading" do
		it "returns appropriate heading if new view" do
			helper.instance_variable_set(:@term_record, TermRecord.new)
			expect(helper.add_or_change_collection_heading).to match(/Add/)
		end

		it "returns appropriate heading if edit view" do
			helper.instance_variable_set(:@term_record, FactoryGirl.create(:term_record))
			expect(helper.add_or_change_collection_heading).not_to match(/Add/)
		end
	end

	describe "#lang_fields" do
		it "returns an array with length equal to default collection's active languages" do
			helper.instance_variable_set(:@default_collection, FactoryGirl.create(:collection))
		  expect(helper.lang_fields.length).to eq(2)
		  expect(helper.lang_fields).to be_an(Array)
		end
	end

	describe "#source_name" do
		it "return a string if record has a source" do
			helper.instance_variable_set(:@term_record, FactoryGirl.create(:term_record))
			expect(helper.source_name).to be_a(String)
		end

		it "returns nil if no source has been set" do
			helper.instance_variable_set(:@term_record, TermRecord.new)
			expect(helper.source_name).to be_nil
		end
	end

	describe "#domain_name" do
		it "returns a string if record has a source" do
			helper.instance_variable_set(:@term_record, FactoryGirl.create(:term_record))
			expect(helper.domain_name).to be_a(String)
		end

		it "returns nil if no source has been set" do
			helper.instance_variable_set(:@term_record, TermRecord.new)
			expect(helper.domain_name).to be_nil
		end
	end

	describe "#lang_columns" do
		it "returns an array with length equal to term record's collection's active languages" do
			t = FactoryGirl.create(:term_record)
			expect(helper.lang_columns(t)).to be_an(Array)
			expect(helper.lang_columns(t).length).to eq(2)
		end
	end

	describe "#current_or_default_collection" do
		it "returns the record's collection id if any" do
			t = FactoryGirl.build(:term_record)
			helper.instance_variable_set(:@term_record, t)
			expect(helper.current_or_default_collection).to eq(t.collection_id)
		end

		it "returns the default collection's id if record has no collection" do
			t = FactoryGirl.build(:term_record)
			t.collection_id = nil
			helper.instance_variable_set(:@term_record, t)

			default = FactoryGirl.build(:collection)
			helper.instance_variable_set(:@default_collection, default)

			expect(helper.current_or_default_collection).to eq(default.id)
		end
	end
end