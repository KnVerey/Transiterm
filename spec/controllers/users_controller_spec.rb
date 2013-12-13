require 'spec_helper'

describe UsersController do

  let(:person) { FactoryGirl.create(:user, email: "email#{rand(1000)}@test.com") }
  let(:valid_attributes) { {
    first_name: "Test",
    last_name: "Test",
    email: "test@gmail.com",
    password: "password1",
    password_confirmation: "password1"
   }}

  describe "GET show" do
    it "sets @user to current_user" do
      login_user(person)
      get :show, { id: person.to_param }
      assigns(:user).should eq(controller.current_user)
    end

    it "doesn't show someone else's profile if other id in params" do
      login_user(person)
      get :show, { id: rand(1000) }
      assigns(:user).should eq(person)
    end
  end

  describe "GET new" do
    it "is available to logged out users" do
      get :new
      expect(response.status).to eq(200)
    end

    it "assigns a new user as @user" do
      get :new
      assigns(:user).kind_of?(User).should be_true
    end
  end

  describe "GET edit" do
    it "sets @user to current_user" do
      login_user(person)
      get :edit, { id: person.to_param }
      assigns(:user).should eq(controller.current_user)
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
    describe "with valid params" do

      it "sets @user to current_user" do
        login_user(person)
        put :update, id: person.to_param, user: { id: person.to_param, email: "test@test.com" }
        assigns(:user).should eq(controller.current_user)
      end

      it "updates the requested user" do
        login_user(person)
        person.should_receive(:update).with("email" => "test@test.com")
        put :update, id: person.to_param, user: { id: person.to_param, email: "test@test.com" }
      end

      it "redirects if user not logged in" do
        put :update, {id: person.to_param, user: valid_attributes}
        expect(response).to redirect_to("/login")
      end

      it "redirects to the user page if success" do
        login_user(person)
        put :update, {:id => person.to_param, :user => valid_attributes}
        response.should redirect_to("/users/#{person.id}")
      end
    end

    describe "with invalid params" do

      it "re-renders the 'edit' template" do
        login_user(person)
        person.stub(:save).and_return(false)
        put :update, { id: person.to_param, user: { "email" => "invalid value" }}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do

    it "sets @user to current_user" do
      login_user(person)
      delete :destroy, { id: person.to_param }
      assigns(:user).should eq(controller.current_user)
    end

    it "destroys the requested user" do
      login_user(person)
      expect {
        delete :destroy, {:id => person.to_param}
      }.to change(User, :count).by(-1)
    end

    it "redirects to the home page" do
      login_user(person)
      delete :destroy, {:id => person.to_param}
      response.should redirect_to("/home")
    end
  end

  describe "GET activate" do
    before(:each) do
      @activate_me = FactoryGirl.create(:inactive_user, email: "email#{rand(1000)}@test.com")
    end

    describe "with a valid token" do
      it "logs the user in" do
        get :activate, {:id => @activate_me.activation_token}
        expect(controller.current_user).to_not be_false
      end

      it "redirects to the user's collections" do
        get :activate, {:id => @activate_me.activation_token}
        expect(response).to redirect_to("/users/#{@activate_me.id}/collections")
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
      @unlock_me = FactoryGirl.create(:locked_user, email: "email#{rand(1000)}@test.com")
    end

    describe "with a valid token" do
      it "logs the user in" do
        get :unlock, {:id => @unlock_me.unlock_token}
        expect(controller.current_user).to_not be_false
      end

      it "redirects to the user's collections" do
        get :unlock, {:id => @unlock_me.unlock_token}
        expect(response).to redirect_to("/users/#{@unlock_me.id}/collections")
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
