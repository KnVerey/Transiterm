require 'spec_helper'

describe UsersController do

  let(:person) { FactoryGirl.create(:active_user) }
  let(:valid_attributes) { {
    first_name: "Test",
    last_name: "Test",
    email: "test@gmail.com",
    password: "password1",
    password_confirmation: "password1"
   }}

  describe "GET new" do
    it "is available to logged out users" do
      skip 'user creation disabled'
      get :new
      expect(response.status).to eq(200)
    end

    it "is not available" do
      get :new
      expect(response).to redirect_to(login_path)
    end

    it "assigns a new user as @user" do
      skip 'user creation disabled'
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe "GET edit" do
    it "assigns current_user as @user (to share 'new' form)" do
      login_user(person)
      get :edit, { id: person.to_param }
      expect(assigns(:user)).to eq(person)
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

      it "calls toggle_language on the current_user" do
        expect(person).to receive(:toggle_language).with("english")
        User.any_instance.stub(:toggle_language)
        controller.stub(:current_user).and_return(person)
        get :lang_toggle, { user_id: person.id, lang_toggle: "english" }
      end

      it "redirects to the query page" do
        User.any_instance.stub(:toggle_language)
        controller.stub(:current_user).and_return(person)
        get :lang_toggle, { user_id: person.id, lang_toggle: "english" }
        expect(response).to redirect_to('/query')
      end
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "is not available" do
        get :new
        expect(response).to redirect_to(login_path)
      end

      it "creates a new User" do
        skip 'user creation disabled'
        expect {
          post :create, user: valid_attributes
        }.to change(User, :count).by(1)
      end

      it "saves the new user to the db" do
        skip 'user creation disabled'
        post :create, user: valid_attributes
        expect(assigns(:user)).to be_a(User)
        expect(assigns(:user)).to be_persisted
      end

      it "does not log in the new user" do
        skip 'user creation disabled'
        post :create, user: valid_attributes
        expect(controller.current_user).to be false
      end

      it "redirects to the login page" do
        skip 'user creation disabled'
        post :create, user: valid_attributes
        expect(response).to redirect_to("/login")
      end

      it "alerts user to check for activation email" do
        skip 'user creation disabled'
        post :create, user: valid_attributes
        expect(flash[:success]).to match(/email/i)
      end
    end

    describe "with invalid params" do
      it "does not allow creation without password and confirmation" do
        skip 'user creation disabled'
        bad_user = { first_name: "Test", last_name: "Test", email: "test@gmail.com", password: "password1" }
        User.any_instance.stub(:save).and_return(false)
        post :create, user: bad_user

        expect(assigns(:user)).not_to be_valid
      end

      it "assigns a newly created but unsaved user as @user" do
        skip 'user creation disabled'
        User.any_instance.stub(:save).and_return(false)
        post :create, user: { email: "invalid value" }
        expect(assigns(:user)).to be_a_new(User)
      end

      it "re-renders the 'new' template" do
        skip 'user creation disabled'
        User.any_instance.stub(:save).and_return(false)
        post :create, user: { "email" => "invalid value" }
        expect(response).to render_template("new")
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
        expect(assigns(:user)).to be_nil
        expect(assigns(:current_user)).not_to be_nil
      end

      describe "with valid params" do

        it "updates the requested user without password" do
          expect(person).to receive(:update).with("email" => "test@test.com")
          put :update, id: person.to_param, user: { id: person.to_param, email: "test@test.com" }
        end

        it "redirects to the same page if success" do
          put :update, {:id => person.to_param, :user => valid_attributes}
          expect(response).to redirect_to("/users/#{person.id}/edit")
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
          expect(response).to render_template("edit")
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
        expect(assigns(:user)).to be_nil
        expect(assigns(:current_user)).not_to be_nil
      end

      it "destroys the requested user" do
        expect {
          delete :destroy, {:id => person.to_param}
        }.to change(User, :count).by(-1)
      end

      it "redirects to the home page" do
        delete :destroy, {:id => person.to_param}
        expect(response).to redirect_to("/")
      end
    end
  end

  describe "GET activate" do
    before(:each) do
      @activate_me = FactoryGirl.create(:user)
    end

    describe "with a valid token" do
      it "logs the user in" do
        skip 'user creation disabled'
        get :activate, {:id => @activate_me.activation_token}
        expect(controller.current_user).to_not be false
      end

      it "redirects to the query page" do
        skip 'user creation disabled'
        get :activate, {:id => @activate_me.activation_token}
        expect(response).to redirect_to("/query")
      end
    end

    describe "with invalid token" do
      it "alerts the user of a problem with token" do
        skip 'user creation disabled'
        User.any_instance.stub(:load_from_activation_token).and_return(false)
        get :activate, {id: "invalid_id"}
        expect(flash[:alert]).to match(/token/i)
      end

      it "redirects to the login screen" do
        skip 'user creation disabled'
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
        skip 'user creation disabled'
        get :unlock, {:id => @unlock_me.unlock_token}
        expect(controller.current_user).to_not be false
      end

      it "redirects to the query page" do
        skip 'user creation disabled'
        get :unlock, {:id => @unlock_me.unlock_token}
        expect(response).to redirect_to("/query")
      end
    end

    describe "with invalid token" do
      it "alerts the user of a problem with token" do
        skip 'user creation disabled'
        User.any_instance.stub(:load_from_unlock_token).and_return(false)
        get :unlock, {id: "invalid_id"}
        expect(flash[:alert]).to match(/token/i)
      end

      it "redirects to the login screen" do
        skip 'user creation disabled'
        User.any_instance.stub(:load_from_unlock_token).and_return(false)
        get :unlock, {id: "invalid_id"}
        expect(response).to redirect_to("/login")
      end
    end
  end
end
