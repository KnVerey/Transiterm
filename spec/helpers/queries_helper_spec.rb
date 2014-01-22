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
		context "when not all collections displayed are active" do
			before(:each) { helper.stub(:all_displayed_active?).and_return(false) }

			it "returns a string if collection is active" do
				helper.instance_variable_set(:@selected_collections, [c])
				expect(helper.collection_active_class(c)).to be_a(String)
			end

			it "returns nil if collection is not active" do
				c2 = FactoryGirl.build(:collection, user: person)
				helper.instance_variable_set(:@selected_collections, [c2])
				expect(helper.collection_active_class(c)).to be_nil
			end
		end

		context "when all collections displayed are active" do
			before(:each) { helper.stub(:all_displayed_active?).and_return(true) }

			it "returns nil" do
				helper.instance_variable_set(:@selected_collections, [c])
				expect(helper.collection_active_class(c)).to be_nil
			end
		end
	end

	describe "#all_active_class" do
		it "returns a string if all collections displayed are active"
		it "returns nil when not all collections displayed are active"
	end

	describe "#all_displayed_active?" do
		it "returns true if all collections displayed are active" do
			c2 = FactoryGirl.create(:collection, user: person)
			c3 = FactoryGirl.create(:collection, user: person)

			helper.instance_variable_set(:@sidebar_collections, [c3, c2, c])
			helper.instance_variable_set(:@selected_collections, [c, c3, c2])

			expect(helper.all_displayed_active?).to eq(true)
		end

		it "returns false if not all collections displayed are active" do
			c2 = FactoryGirl.create(:collection, user: person)
			c3 = FactoryGirl.create(:collection, user: person)

			helper.instance_variable_set(:@sidebar_collections, [c3, c, c2])
			helper.instance_variable_set(:@selected_collections, [c])

			expect(helper.all_displayed_active?).to eq(false)
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

	describe "#any_collections_active?" do
		it "returns false if @sidebar_collections is empty" do
			helper.instance_variable_set(:@sidebar_collections, [])
			expect(helper.any_collections_active?).to eq(false)
		end

		it "returns true if @sidebar_collections not empty" do
			helper.instance_variable_set(:@sidebar_collections, [c])
			expect(helper.any_collections_active?).to eq(true)
		end
	end

	describe "#collection_button_size" do
		it "returns 'small-5' if existing collections active" do
			helper.instance_variable_set(:@sidebar_collections, [c])
			expect(helper.collection_button_size).to eq("small-5")
		end

		it "returns 'small-12' if no existing collections active" do
			helper.instance_variable_set(:@sidebar_collections, [])
			expect(helper.collection_button_size).to eq("small-12")
		end
	end

	describe "#pluralized_this_language" do
		it "returns 'this language' if one lang active" do
			person.stub(:active_languages).and_return(["English"])
			expect(helper.pluralized_this_language).to eq("this language")
		end

		it "returns 'these languages' if multiple langs active" do
			expect(helper.pluralized_this_language).to eq("these languages")
		end
	end

end
