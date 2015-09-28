require 'spec_helper'

describe PagesController do

	describe "GET home" do
		it "should render home template when no current_user" do
			get :home
			expect(response).to render_template("home")
		end

		it 'should redirect when logged in' do
			skip 'login currently disabled'
			user = FactoryGirl.create(:active_user)
			login_user(user)

			get :home

			expect(response).to redirect_to("/query")
		end
	end

	describe "GET features" do
		it "should render features template when no current_user" do
			get :features
			expect(response).to render_template("features")
		end

		it "should render features template when logged in" do
			user = FactoryGirl.create(:active_user)
			login_user(user)

			get :features

			expect(response).to render_template("features")
		end
	end

	describe "GET v2" do
		it "should render v2 template when no current_user" do
			get :v2
			expect(response).to render_template("v2")
		end
	end

	describe "GET download" do
		it "should render download template when no current_user" do
			get :download
			expect(response).to render_template("download")
		end
	end
end
