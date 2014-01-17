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

			it "sets @sidebar_collections" do
			  get :show
			  expect(assigns(:sidebar_collections)).not_to be_nil
			end

			it "sets @selected_collections" do
			  get :show
			  expect(assigns(:selected_collections)).not_to be_nil
			end

			it "sets @term_records" do
			  get :show
			  expect(assigns(:term_records)).not_to be_nil
			end

		end
	end
end
