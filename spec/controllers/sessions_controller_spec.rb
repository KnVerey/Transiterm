require 'spec_helper'

describe SessionsController do
  let!(:user) { FactoryGirl.create(:user) }

  describe "GET new" do
    it "assigns a virtual user" do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "POST create" do
    describe "when account found" do
      it "redirects to users's collections on login success" do
        controller.stub(:login).and_return(User.last)

        post :create, email: user.email, password: user.password

        expect(response).to redirect_to("/users/#{user.id}/collections")
      end

      it "flashes login success message" do
        controller.stub(:login).and_return(User.last)

        post :create, email: user.email, password: user.password

        flash[:success].should_not be_nil
      end
    end

    describe "when login params invalid" do

      it "renders new when login failed" do
        post :create, email: "notvalid@email.com", password: "notvalid"

        expect(response).to render_template("new")
      end

      it "flashes failure message on login failure" do
        post :create, email: "notvalid@email.com", password: "notvalid"

        flash[:alert].should_not be_nil
      end

      it "tells the user they're locked out when applicable" do
        locked_user = FactoryGirl.create(:locked_user)
        post :create, email: locked_user.email, password: "notvalid"

        expect(flash[:alert]).to match(/locked/i)
      end
    end
  end

  describe "POST destroy" do
    it "redirects to the login page on logout" do
      login_user(user)
      post :destroy

      expect(response).to redirect_to("/login")
    end
  end

end
