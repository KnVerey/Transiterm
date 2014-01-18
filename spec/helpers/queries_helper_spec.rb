require 'spec_helper'

describe QueriesHelper do
	let(:person) { FactoryGirl.create(:user) }
	let(:c) { FactoryGirl.create(:collection, user: person) }

	before(:each) { helper.stub(:current_user).and_return(person) }

	describe "#set_columns" do
		it "returns an array (of active langs)" do
			expect(helper.set_columns).to be_an(Array)
		end

		it "returns array with length between 0 and all langs" do
			max_possible = Collection::LANGUAGES.length

			expect(0..max_possible).to include(helper.set_columns.length)
		end
	end

	describe "#set_fields" do
		it "returns an array (of fields)" do
		  expect(helper.set_fields).to be_an(Array)
		end

		it "returns array with length btw 0 and all langs + all fields" do
		  max_possible = Collection::LANGUAGES.length + Collection::FIELDS.length

		  expect(0..max_possible).to include(helper.set_fields.length)
		end
	end

	describe "#lang_active_class" do
		it "returns a string if french active" do
			expect(helper.lang_active_class("French")).to be_a(String)
		end

		it "returns a string if english active" do
			expect(helper.lang_active_class("English")).to be_a(String)
		end

		it "returns a string if spanish active" do
			person.spanish_active = true
			expect(helper.lang_active_class("Spanish")).to be_a(String)
		end

		it "returns nil if lang not active" do
			person.spanish_active = false
			expect(helper.lang_active_class("Spanish")).to be_nil
		end
	end

	describe "#collection_active_class" do
		it "returns a string if the collection is active by user" do
			person.active_collection_ids << c.id
			helper.instance_variable_set(:@selected_collections, [c])

		  expect(helper.collection_active_class(c)).to be_a(String)
		end

		it "returns nil if collection is active by default (none selected)" do
			person.active_collection_ids = []
			helper.instance_variable_set(:@selected_collections, [c])

		  expect(helper.collection_active_class(c)).to be_nil
		end

		it "returns nil if collection not active" do
			d = FactoryGirl.create(:collection, user: person)
			person.active_collection_ids << d.id
			helper.instance_variable_set(:@selected_collections, [d])

		  expect(helper.collection_active_class(c)).to be_nil
		end
	end

	describe "#all_active_class" do
		it "returns a string if all active by default" do
			person.active_collection_ids = []
			helper.instance_variable_set(:@selected_collections, [c])

		  expect(helper.all_active_class).to be_a(String)
		end

		it "returns nil if all active by user" do
			person.active_collection_ids << c.id
			helper.instance_variable_set(:@selected_collections, [c])

		  expect(helper.all_active_class).to be_nil
		end
	end

	describe "#no_languages_active?" do
		it "returns false if any languages active" do
		  expect(helper.no_languages_active?).to eq(false)
		end

		it "returns true if no languages active" do
			person.french_active = false
			person.english_active = false
		  expect(helper.no_languages_active?).to eq(true)
		end
	end

end
