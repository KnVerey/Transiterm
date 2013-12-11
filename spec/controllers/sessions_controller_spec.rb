require 'spec_helper'

describe SessionsController do

  describe "GET new" do
    it "assigns a virtual user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST create" do
    it "redirects to users's collections on login success" do
      user = FactoryGirl.create(:user)

      post :create, email: user.email, password: user.password

      expect(response).to redirect_to("/users/#{user.id}/collections")

    end

    it "flashes login success message" do
      user = FactoryGirl.create(:user)

      post :create, email: user.email, password: user.password

      flash[:success].should_not be_nil
    end

    it "renders new when login failed" do
      post :create, email: "notvalid@email.com", password: "notvalid"

      expect(response).to render_template("new")
    end

    it "flashes failure message on login failure" do
      post :create, email: "notvalid@email.com", password: "notvalid"

      flash[:alert].should_not be_nil
    end
  end

  describe "POST destroy" do
    it "redirects to the login page on logout" do
      login_user(FactoryGirl.create(:user))
      post :destroy

      expect(response).to redirect_to("/login")
    end
  end

end
