require 'spec_helper'

describe CollectionsController do

  let(:person) { FactoryGirl.create(:active_user) }
  let!(:person_collection) { FactoryGirl.create(:collection, user: person) }

  let(:valid_attributes) { {
  	title: "Music",
  	description: "For music studio client",
  	english: true,
  	french: true,
  	spanish: false
  } }

	describe "GET new" do
		it "redirects if user not logged in" do
		  get :new
		  expect(response).to redirect_to("/login")
		end

		it "assigns a new collection as @collection" do
		  login_user(person)
		  get :new
		  assigns(:collection).should be_a_new(Collection)
		end
	end

	describe "POST create" do
		context "when user not logged in" do
			it "redirects if user not logged in" do
			  post :create, { collection: valid_attributes }
			  expect(response).to redirect_to("/login")
			end

			it "does not save if user not logged in" do
				  expect {
				  	post :create, collection: valid_attributes
				  }.not_to change(Collection, :count)
			end
		end

		context "when user logged in" do
			before(:each) { login_user(person) }

			describe "with valid params" do
				it "creates a new collection" do
				  expect {
				  	post :create, collection: valid_attributes
				  }.to change(Collection, :count).by(1)
				end

				it "saves current_user's id in the collection" do
					post :create, collection: valid_attributes
					assigns(:collection).user_id.should eq(person.id)
				end

				it "adds the new collection to the active list" do
					post :create, collection: valid_attributes
					new_id = assigns(:collection).id

					expect(person.active_collection_ids).to include(new_id)
				end

				it "changes the active languages to match the collection's" do
					post :create, collection: { title: "Music", description: "For music studio client", english: false, french: false, spanish: true }
					expect(person.active_languages).to match_array(["spanish"])
				end

				it "redirects to the query page" do
				  post :create, collection: valid_attributes
				  expect(response).to redirect_to("/query")
				end
			end

			describe "with invalid params" do
				it "assigns a newly created but unsaved collection as @collection" do
				  Collection.any_instance.stub(:save).and_return(false)
				  post :create, collection: {nothing: "bad params"}
				  assigns(:collection).should be_a_new(Collection)
				end

				it "re-renders the 'new' template" do
				  User.any_instance.stub(:save).and_return(false)
				  post :create, collection: { description: "bad params" }
				  expect(response).to render_template("new")
				end
			end
		end
	end

	describe "GET edit" do
		it "redirects if user not logged in" do
		  get :edit, { id: person_collection.to_param }
		  expect(response).to redirect_to("/login")
		end

		it "redirects if the collection does not belong to the user" do
			login_user(person)
			collection = FactoryGirl.create(:collection)
		  get :edit, { id: collection.to_param }
			expect(response).to redirect_to("/query")
		end

    it "sets @collection to requested collection" do
      login_user(person)
      get :edit, { id: person_collection.to_param }
      assigns(:collection).should eq(person_collection)
    end

		it "renders the view if user logged in" do
			login_user(person)
		  get :edit, { id: person_collection.to_param }
			expect(response.status).to eq(200)
		end
	end

	describe "PUT update" do
		context "when user not logged in" do
			it "redirects if user not logged in" do
		  	put :update, { id: person_collection.to_param }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when user logged in" do
			before(:each) { login_user(person) }

			it "will not update someone else's record" do
				collection = FactoryGirl.create(:collection)
				controller.stub(:current_user).and_return(person)
				Collection.stub(:find).and_return(collection)

				expect(collection).not_to receive(:update)
				put :update, id: collection.to_param, collection: { title: "Coin collecting" }
			end

			context "with valid params" do
				it "updates the current user's specified collection" do
				  Collection.stub(:find).and_return(person_collection)
				  person_collection.should_receive(:update).with({"title" => "Ornithology"})
				  put :update, id: person_collection.id, collection: {id: person_collection.id, title: "Ornithology"}
				end

				it "redirects to the query page if success" do
				  Collection.any_instance.stub(:update).and_return(true)
				  put :update, id: person_collection.to_param, collection: {title: "Coin collecting", description: "New hobby"}
				  expect(response).to redirect_to("/query")
				end
			end

			context "with invalid params" do
				it "re-renders the 'edit' template" do
				  Collection.any_instance.stub(:update).and_return(false)
				  put :update, id: person_collection.to_param, collection: {invalid: "false"}
				  expect(response).to render_template("edit")
				end
			end
		end
	end

	describe "DELETE destroy" do
		context "when user not logged in" do
			it "redirects if user not logged in" do
		  	delete :destroy, { id: person_collection.to_param }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when user logged in" do
			before(:each) { login_user(person) }

	    it "sets @collection to requested collection" do
	      delete :destroy, { id: person_collection.to_param }
	      assigns(:collection).should eq(person_collection)
	    end

	    it "does not destroy anything unless collection belongs to user" do
	    	collection = FactoryGirl.create(:collection)
	      expect {
  	      delete :destroy, { id: collection.to_param }
  	      }.not_to change(Collection, :count)
	    end

	    it "destroys the requested collection" do
	      expect {
	        delete :destroy, {id: person_collection.to_param, user_id: person.to_param}
	      }.to change(Collection, :count).by(-1)
	    end

	    it "removes the collection from the active list, if there" do
				person.active_collection_ids_will_change!
				person.active_collection_ids << person_collection.id
				person.save

				expect {
					delete :destroy, {id: person_collection.to_param, user_id: person.to_param}
				}.to change(person.active_collection_ids, :length).by(-1)
	    end

	    it "leaves the collections active list alone if not in it" do
				expect {
					delete :destroy, {id: person_collection.to_param, user_id: person.to_param}
				}.not_to change(person.active_collection_ids, :length)
	    end

	    it "redirects to the user's query page" do
	      delete :destroy, {:user_id => person.to_param, id: person_collection.to_param}
	      response.should redirect_to("/query")
	    end
	  end
  end
end
