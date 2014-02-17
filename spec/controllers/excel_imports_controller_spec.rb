require 'spec_helper'

describe ExcelImportsController do

	let(:person) { FactoryGirl.create(:active_user) }

	describe "GET new" do
		it "redirects if user not logged in" do
		  get :new
		  expect(response).to redirect_to("/login")
		end

		it "assigns a new excel import as @importer" do
			login_user(person)
		  get :new
			expect(assigns(:importer)).to be_an(ExcelImport)
		end

		it "respondes with 200 status" do
		  login_user(person)
		  get :new
		  expect(response.status).to eq(200)
		end
	end

	describe "POST create" do
		it "redirects if user not logged in" do
		  post :create
		  expect(response).to redirect_to("/login")
		end

		it "assigns a new excel import as @importer with current_user as its user" do
			controller.stub(:current_user).and_return(person)
		  post :create
		  expect(assigns(:importer)).to be_an(ExcelImport)
		  expect(assigns(:importer).user).to eq(person)
		end
	end
end
