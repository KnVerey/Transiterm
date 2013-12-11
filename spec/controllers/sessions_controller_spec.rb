require 'spec_helper'

describe SessionsController do

  describe "GET new" do
    it "assigns a virtual user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET create" do
    xit "redirects to users's collections on login success" do
      user = FactoryGirl.create(:user)

      post :create, email: user.email, password: user.password

      expect(response).to redirect_to("/users/#{user.id}/collections")
    end

    xit "flashes login success message" do
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

  describe "GET 'destroy'" do
    xit "returns http success" do
      get 'destroy'
      response.should be_success
    end
  end

end
