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

  describe "GET show" do
    it "assigns the requested user as @user" do
      login_user(person)
      get :show, { id: person.to_param }
      assigns(:user).should eq(person)
    end

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
    it "assigns the requested user as @user" do
      login_user(person)
      get :edit, { id: person.to_param}
      assigns(:user).should eq(person)
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
      xit "updates the requested user" do
        login_user(person)
        person.should_receive(:update).with({ email: "test@test.com" })
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
      xit "assigns the user as @user" do
        user = User.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => { "email" => "invalid value" }}, valid_session
        assigns(:user).should eq(user)
      end

      xit "re-renders the 'edit' template" do
        user = User.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        User.any_instance.stub(:save).and_return(false)
        put :update, {:id => user.to_param, :user => { "email" => "invalid value" }}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    xit "destroys the requested user" do
      user = User.create! valid_attributes
      expect {
        delete :destroy, {:id => user.to_param}, valid_session
      }.to change(User, :count).by(-1)
    end

    xit "redirects to the users list" do
      user = User.create! valid_attributes
      delete :destroy, {:id => user.to_param}, valid_session
      response.should redirect_to(users_url)
    end
  end

end
