require 'spec_helper'

describe PagesController do



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