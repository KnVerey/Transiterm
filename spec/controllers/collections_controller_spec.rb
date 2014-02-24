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
		  expect {
		  	get :edit, { id: collection.to_param }
			}.to raise_error(ActiveRecord::RecordNotFound)
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

			it "throws an error if tries to update someone else's record" do
				collection = FactoryGirl.create(:collection)

				expect {
					put :update, id: collection.to_param, collection: { title: "Coin collecting" }
				}.to raise_error(ActiveRecord::RecordNotFound)
			end

			context "with valid params" do
				it "updates the current user's specified collection" do
					controller.stub(:find_collection)
					controller.instance_variable_set(:@collection, person_collection)

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

	    it "raises an error if attempt to destroy collection that does not belong to user" do
	    	collection = FactoryGirl.create(:collection)
	      expect {
  	      delete :destroy, { id: collection.to_param }
  	      }.to raise_error(ActiveRecord::RecordNotFound)
	    end

	    it "destroys the requested collection" do
	      expect {
	        delete :destroy, {id: person_collection.to_param, user_id: person.to_param}
	      }.to change(Collection, :count).by(-1)
	    end

	    it "redirects to the user's query page" do
	      delete :destroy, {:user_id => person.to_param, id: person_collection.to_param}
	      response.should redirect_to("/query")
	    end
	  end
  end

  describe "GET activate_alone" do
    context "when logged out" do
      it "redirects to the login page" do
        get :activate_alone, {id: person_collection.id}
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before(:each) { login_user(person) }
      it "redirects to the query page" do
        get :activate_alone, {id: person_collection.id}
        expect(response).to redirect_to('/query')
      end

      it "activates the collection" do
      	person_collection.active = false
      	person_collection.save
        get :activate_alone, {id: person_collection.id}
        expect(assigns(:collection).active).to be_true
      end

      it "deactives other visible collections" do
        c = FactoryGirl.create(:collection, user: person, active: true)
        c1 = FactoryGirl.create(:collection, user: person, active: true)
        c2 = FactoryGirl.create(:collection, user: person, active: true)
        get :activate_alone, {id: c.id}
        any_active = [c1, c2].any? { |x| x.reload.active }
        expect(any_active).to be_false
      end
   	end
  end

  describe "GET toggle" do
    context "when logged out" do
      it "redirects to the login page" do
    	  get :toggle, { id: person_collection.id }
        expect(response).to redirect_to(login_path)
      end
    end

    context "when logged in" do
      before(:each) { login_user(person) }
      it "redirects to the query page" do
        User.any_instance.stub(:toggle_collection)
    	  get :toggle, { id: person_collection.id }
        expect(response).to redirect_to('/query')
      end

      context "without 'all' in the params" do
      	it "calls toggle on the collection" do
      		Collection.any_instance.stub(:toggle)
      	  get :toggle, { id: person_collection.id }
      	  expect(assigns(:collection)).to have_received(:toggle)
      	end
      end

      context "with 'all' in the params" do
      	it "calls toggle_all on collection" do
      	  expect(Collection).to receive(:toggle_all)
      	  get :toggle, { id: person_collection.id, all: true }
      	end
      end
   	end
  end
end
