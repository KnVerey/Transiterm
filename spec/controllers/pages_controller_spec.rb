require 'spec_helper'

describe PagesController do

	describe "GET home" do
		it "should render home template when no current_user" do
			get :home
			expect(response).to render_template("home")
		end

		it 'should redirect when logged in' do
			user = FactoryGirl.create(:user)
			login_user(user)

			get :home

			expect(response).to redirect_to("/users/#{user.id}/collections")
		end
	end

	describe "GET access" do
		it "should render access template when no current_user" do
			get :msaccess
			expect(response).to render_template("msaccess")
		end

		it "should render access template when logged in" do
			user = FactoryGirl.create(:user)
			login_user(user)

			get :msaccess

			expect(response).to render_template("msaccess")
		end
	end

end