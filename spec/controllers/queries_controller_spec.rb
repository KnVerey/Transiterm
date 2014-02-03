require 'spec_helper'

describe QueriesController do

  let(:person) { FactoryGirl.create(:active_user) }

	describe "GET index" do
		context "when not logged in" do
			it "redirects to the login page" do
			  get :index
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "sets @sidebar_collections correctly" do
				FactoryGirl.create(:collection, user: person)
				FactoryGirl.create(:collection, user: person)
				FactoryGirl.create(:three_lang_collection, user: person)

			  get :index
			  expect(assigns(:sidebar_collections)).not_to be_empty
			  expect(assigns(:sidebar_collections).length).to eq(2)
			end

			it "sets @selected_collections correctly" do
				c = FactoryGirl.create(:collection, user: person)
				FactoryGirl.create(:collection, user: person)
				FactoryGirl.create(:three_lang_collection, user: person)

				person.active_collection_ids << c.id
			  get :index
			  expect(assigns(:selected_collections)).not_to be_empty
			  expect(assigns(:selected_collections).length).to eq(1)
			end

			it "sets @search with a FullTextSearch" do
				search = FactoryGirl.build(:full_text_search)
				FullTextSearch.stub(:new).and_return(search)

			  get :index
			  expect(assigns(:search)).to be_a(FullTextSearch)
			end

			it "saves the search results in @term_records" do
				search = FactoryGirl.build(:full_text_search)
				FullTextSearch.stub(:new).and_return(search)
				search.stub(:results).and_return([])

				expect(search).to receive(:results)
			  get :index
			  expect(assigns(:term_records)).not_to be_nil
			end

		end
	end
end
