require 'spec_helper'

describe QueriesController do

  let(:person) { FactoryGirl.create(:active_user) }

  let(:person_collection) { FactoryGirl.create(:three_lang_collection, user: person) }

  let(:record) { FactoryGirl.create(:term_record, collection: person_collection) }


	describe "GET show" do
		context "when not logged in" do
			it "redirects to the login page" do
			  get :show
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "sets @fields" do
			  get :show
			  assigns(:fields).should_not be_nil
			end

			it "sets @columns" do
			  get :show
			  assigns(:columns).should_not be_nil
			end

			xit "sanitizes the search field" do
				get :show, field: "Garbage"
				expect(assigns(:query).search_field).to be_nil
			end

			xit "downcases valid search fields" do
			  get :show, field: "English"
				expect(assigns(:query).search_field).to eq("english")
			end

			it "sets @sidebar_collections" do
			  get :show
			  expect(assigns(:sidebar_collections)).not_to be_nil
			end

			it "sets @collections_for_search" do
			  get :show
			  expect(assigns(:collections_for_search)).not_to be_nil
			end

			it "sets @term_records" do
			  get :show
			  expect(assigns(:term_records)).not_to be_nil
			end

		end
	end
end
