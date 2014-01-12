require 'spec_helper'

describe UsersController do

  let(:person) { FactoryGirl.create(:user) }
  let(:valid_attributes) { {
    first_name: "Test",
    last_name: "Test",
    email: "test@gmail.com",
    password: "password1",
    password_confirmation: "password1"
   }}

  describe "GET new" do
    it "is available to logged out users" do
      get :new
      expect(response.status).to eq(200)
    end

    it "assigns a new user as @user" do
      get :new
      assigns(:user).should be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns current_user as @user (to share 'new' form)" do
      login_user(person)
      get :edit, { id: person.to_param }
      assigns(:user).should eq(person)
    end
  end

  describe "GET lang_toggle" do
    context "when logged out" do
      it "redirects to the login page" do
        get :lang_toggle
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before(:each) { login_user(person) }

      it "uses param to toggle active languages" do
        person.should_receive(:toggle_language).with("english")
        User.any_instance.stub(:save)
        controller.stub(:current_user).and_return(person)
        get :lang_toggle, { user_id: person.id, lang_toggle: "english" }
      end

      it "redirects to the collections index" do
        get :lang_toggle, { user_id: person.id, lang_toggle: "english" }
        expect(response).to redirect_to('/collections')
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do

      it "creates a new User" do
        expect {
          post :create, user: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "saves the new user to the db" do
        post :create, user: valid_attributes
        assigns(:user).should be_a(User)
        assigns(:user).should be_persisted
      end

      it "does not log in the new user" do
        post :create, user: valid_attributes
        expect(controller.current_user).to be_false
      end

      it "redirects to the login page" do
        post :create, user: valid_attributes
        response.should redirect_to("/login")
      end

      it "alerts user to check for activation email" do
        post :create, user: valid_attributes
        expect(flash[:success]).to match(/email/i)
      end
    end

    describe "with invalid params" do
      it "does not allow creation without password and confirmation" do
        bad_user = { first_name: "Test", last_name: "Test", email: "test@gmail.com", password: "password1" }
        User.any_instance.stub(:save).and_return(false)
        post :create, user: bad_user

        assigns(:user).should_not be_valid
      end

      it "assigns a newly created but unsaved user as @user" do
        User.any_instance.stub(:save).and_return(false)
        post :create, user: { email: "invalid value" }
        assigns(:user).should be_a_new(User)
      end

      it "re-renders the 'new' template" do
        User.any_instance.stub(:save).and_return(false)
        post :create, user: { "email" => "invalid value" }
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    context "when user not logged in" do
      it "redirects to login page" do
        put :update, {id: person.to_param, user: valid_attributes}
        expect(response).to redirect_to("/login")
      end
    end

    context "when logged in" do
      before(:each) { login_user(person) }

      it "accesses current_user (no @user)" do
        put :update, id: person.to_param, user: { id: person.to_param, email: "test@test.com" }
        assigns(:user).should be_nil
        assigns(:current_user).should_not be_nil
      end

      describe "with valid params" do

        it "updates the requested user without password" do
          person.should_receive(:update).with("email" => "test@test.com")
          put :update, id: person.to_param, user: { id: person.to_param, email: "test@test.com" }
        end

        it "redirects to the same page if success" do
          put :update, {:id => person.to_param, :user => valid_attributes}
          response.should redirect_to("/users/#{person.id}/edit")
        end

        it "lets the user know it succeeded" do
          User.any_instance.stub(:update).and_return(true)
          put :update, {:id => person.to_param, :user => valid_attributes}
          expect(flash[:success]).to match(/update/i)
        end
      end

      describe "with invalid params" do

        it "doesn't update if password but no confirmation" do
          put :update, id: person.id, user: { id: person.id, email: "test@test.com", password: "test93" }
          expect(response).to render_template("edit")
        end

        it "re-renders the 'edit' template" do
          person.stub(:save).and_return(false)
          put :update, { id: person.to_param, user: { "email" => "invalid value" }}
          response.should render_template("edit")
        end
      end
    end
  end

  describe "DELETE destroy" do

    context "when user not logged in" do
      it "redirects to login page" do
        delete :destroy, { id: person.to_param }
        expect(response).to redirect_to("/login")
      end
    end

    context "when logged in" do
      before(:each) { login_user(person) }

      it "accesses current_user (no @user)" do
        delete :destroy, { id: person.to_param }
        assigns(:user).should be_nil
        assigns(:current_user).should_not be_nil
      end

      it "destroys the requested user" do
        expect {
          delete :destroy, {:id => person.to_param}
        }.to change(User, :count).by(-1)
      end

      it "redirects to the home page" do
        delete :destroy, {:id => person.to_param}
        response.should redirect_to("/home")
      end
    end
  end

  describe "GET activate" do
    before(:each) do
      @activate_me = FactoryGirl.create(:inactive_user)
    end

    describe "with a valid token" do
      it "logs the user in" do
        get :activate, {:id => @activate_me.activation_token}
        expect(controller.current_user).to_not be_false
      end

      it "redirects to the user's collections" do
        get :activate, {:id => @activate_me.activation_token}
        expect(response).to redirect_to("/collections")
      end
    end

    describe "with invalid token" do
      it "alerts the user of a problem with token" do
        User.any_instance.stub(:load_from_activation_token).and_return(false)
        get :activate, {id: "invalid_id"}
        expect(flash[:alert]).to match(/token/i)
      end

      it "redirects to the login screen" do
        User.any_instance.stub(:load_from_activation_token).and_return(false)
        get :activate, {id: "invalid_id"}
        expect(response).to redirect_to("/login")
      end
    end
  end

  describe "GET unlock" do
    before(:each) do
      @unlock_me = FactoryGirl.create(:locked_user)
    end

    describe "with a valid token" do
      it "logs the user in" do
        get :unlock, {:id => @unlock_me.unlock_token}
        expect(controller.current_user).to_not be_false
      end

      it "redirects to the user's collections" do
        get :unlock, {:id => @unlock_me.unlock_token}
        expect(response).to redirect_to("/collections")
      end
    end

    describe "with invalid token" do
      it "alerts the user of a problem with token" do
        User.any_instance.stub(:load_from_unlock_token).and_return(false)
        get :unlock, {id: "invalid_id"}
        expect(flash[:alert]).to match(/token/i)
      end

      it "redirects to the login screen" do
        User.any_instance.stub(:load_from_unlock_token).and_return(false)
        get :unlock, {id: "invalid_id"}
        expect(response).to redirect_to("/login")
      end
    end
  end
end
