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

 	describe "GET index" do
 		context "when not logged in" do
			it "redirects to the login page" do
			  get :index
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in", solr: true do
			before(:each) { login_user(person) }

			context "without a query in params" do
				it "sets @collections" do
				  get :index
				  assigns(:collections).should_not be_nil
				end

				it "sets @collections empty if user has none"

				it "sets @term_records empty if user has none"

				it "sets @term_records to all if any"

				it "sets @columns and @fields" do
				  get :index
				  assigns(:fields).should_not be_nil
				  assigns(:columns).should_not be_nil
				end
			end

			context "with a query in params" do
				before(:each) { controller.stub(:find_relevant_collections).and_return([] << person_collection) }

				it "generates the correct solr query with en field" do
				  get :index, { search: "kitty", field: "English" }
				  assigns(:search).inspect.should match(/:q=>\"kitty\", :fl=>\"\* score\", :qf=>\"english_text\"/)
				end

				it "generates the correct solr query with fr field" do
				  get :index, { search: "sieur", field: "French" }
				  assigns(:search).inspect.should match(/:q=>\"sieur\", :fl=>\"\* score\", :qf=>\"french_text\"/)
				end

				it "generates the correct solr query with sp field" do
					person.spanish_active = true
				  get :index, { search: "hola", field: "Spanish" }
				  assigns(:search).inspect.should match(/:q=>\"hola\", :fl=>\"\* score\", :qf=>\"spanish_text\"/)
				end

				it "generates the correct solr query with domain field" do
				  get :index, { search: "garden", field: "Domain" }
				  assigns(:search).inspect.should match(/:q=>\"garden\", :fl=>\"\* score\", :qf=>\"domain_text\"/)
				end

				it "generates the correct solr query with source field" do
				  get :index, { search: "record", field: "Source" }
				  assigns(:search).inspect.should match(/:q=>\"record\", :fl=>\"\* score\", :qf=>\"source_text\"/)
				end

				it "generates the correct solr query with comment field" do
				  get :index, { search: "record", field: "Comment" }
				  assigns(:search).inspect.should match(/:q=>\"record\", :fl=>\"\* score\", :qf=>\"comment_text\"/)
				end

				it "generates the correct solr query with context field" do
				  get :index, { search: "record", field: "Context" }
				  assigns(:search).inspect.should match(/:q=>\"record\", :fl=>\"\* score\", :qf=>\"context_text\"/)
				end
			end

		end
	end

 	describe "GET show" do
		context "when not logged in" do
			it "redirects if user not logged in" do
			  get :show, { id: person_collection.to_param }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			context "without a query in params" do
				it "sets @collection" do
				  get :show, { id: person_collection.id }
				  assigns(:collection).should_not be_nil
				end

				it "sets @term_records" do
				  get :show, { id: person_collection.id }
				  assigns(:term_records).should_not be_nil
				end

				it "sets @columns and @fields" do
				  get :show, { id: person_collection.id }
				  assigns(:fields).should_not be_nil
				  assigns(:columns).should_not be_nil
				end
			end

			context "with a query in params", solr: true do
				it "generates the correct solr query" do
					FactoryGirl.create(:term_record, collection: person_collection, english: "Hello kitty")
				  get :show, { id: person_collection.id, search: "kitty", field: "English" }
				  assigns(:search).inspect.should match(/:fq=>\[\"type:TermRecord\", \"collection_id_i:1\", \"user_id_i:1\"\], :q=>\"kitty\", :fl=>\"\* score\", :qf=>\"english_text\"/)
				end
			end
		end
	end

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

				it "redirects to the newly create collection" do
				  post :create, collection: valid_attributes
				  expect(response).to redirect_to("/collections/#{assigns(:collection).id}")
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

			context "with valid params" do
				it "updates the current user's specified collection" do
				  Collection.stub(:find).and_return(person_collection)
				  person_collection.should_receive(:update).with({"title" => "Ornithology"})
				  put :update, id: person_collection.id, collection: {id: person_collection.id, title: "Ornithology"}
				end

				it "redirects to the updated collection if success" do
				  Collection.any_instance.stub(:update).and_return(true)
				  put :update, id: person_collection.to_param, collection: {title: "Coin collecting", description: "New hobby"}
				  expect(response).to redirect_to("/collections/#{person_collection.id}")
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

	    it "destroys the requested collection" do
	      expect {
	        delete :destroy, {id: person_collection.to_param, user_id: person.to_param}
	      }.to change(Collection, :count).by(-1)
	    end

	    it "redirects to the user's collections page" do
	      delete :destroy, {:user_id => person.to_param, id: person_collection.to_param}
	      response.should redirect_to("/collections")
	    end
	  end
  end
end
