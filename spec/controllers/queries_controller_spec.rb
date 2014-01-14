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

			it "creates a new query object" do
				get :show
				expect(assigns(:query)).not_to be_nil
			end

			it "sets @fields" do
			  get :show
			  assigns(:fields).should_not be_nil
			end

			it "sets @columns" do
			  get :show
			  assigns(:columns).should_not be_nil
			end
		end
	end
end
