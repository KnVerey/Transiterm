require 'spec_helper'

describe CollectionsController do

  let(:person) { FactoryGirl.create(:user, email: "email#{rand(1000)}@test.com") }
  let(:person_collection) { FactoryGirl.create(:collection, user: person) }

  let(:valid_attributes) { {
  	title: "Music",
  	description: "For music studio client",
  	english: true,
  	french: true,
  	spanish: false
  } }

 	describe "GET index" do
		it "redirects if user not logged in" do
		  get :index, { user_id: person.to_param }
		  expect(response).to redirect_to("/login")
		end

		it "does not give access to other users' collections through url" do
			login_user(person)
			get :index, { user_id: rand(1000) }
			assigns(:collections).should eq(person.collections)
		end
	end

 	describe "GET show" do
		it "redirects if user not logged in" do
		  get :show, { user_id: person.to_param, id: person_collection.to_param }
		  expect(response).to redirect_to("/login")
		end
	end

	describe "GET new" do
		it "redirects if user not logged in" do
		  get :new, { user_id: person.to_param }
		  expect(response).to redirect_to("/login")
		end

		it "assigns a new collection as @collection" do
		  login_user(person)
		  get :new, { user_id: person.to_param }
		  assigns(:collection).kind_of?(Collection).should be_true
		end
	end

	describe "POST create" do
		it "redirects if user not logged in" do
		  post :create, { user_id: person.to_param, collection: valid_attributes }
		  expect(response).to redirect_to("/login")
		end

		it "does not save if user not logged in" do
			  expect {
			  	post :create, user_id: person.to_param, collection: valid_attributes
			  }.not_to change(Collection, :count)
		end

		describe "with valid params" do
			it "creates a new collection" do
				login_user(person)
			  expect {
			  	post :create, user_id: person.to_param, collection: valid_attributes
			  }.to change(Collection, :count).by(1)
			end

			it "redirects to the user's collections index" do
			  login_user(person)
			  Collection.any_instance.stub(:save).and_return(true)
			  post :create, user_id: person.to_param, collection: valid_attributes
			  expect(response).to redirect_to("/users/#{person.id}/collections")
			end
		end

		describe "with invalid params" do
			it "assigns a newly created by unsaved collection as @collection" do
			  login_user(person)
			  User.any_instance.stub(:save).and_return(false)
			  post :create, user_id: person.to_param, collection: { description: "bad params" }
			  assigns(:collection).should be_a_new(Collection)
			end

			it "re-renders the 'new' template" do
			  login_user(person)
			  User.any_instance.stub(:save).and_return(false)
			  post :create, user_id: person.to_param, collection: { description: "bad params" }
			  expect(response).to render_template("new")
			end
		end
	end

	describe "GET edit" do
		it "redirects if user not logged in" do
		  get :edit, { user_id: person.to_param, id: person_collection.to_param }
		  expect(response).to redirect_to("/login")
		end

		it "renders the view if user logged in" do
			login_user(person)
		  get :edit, { user_id: person.to_param, id: person_collection.to_param }
			expect(response.status).to eq(200)
		end
	end
end
