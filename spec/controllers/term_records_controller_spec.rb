require 'spec_helper'

describe TermRecordsController do

  let(:person) { FactoryGirl.create(:user, email: "email#{rand(1000)}@test.com") }

  let(:person_collection) { FactoryGirl.create(:three_lang_collection, user: person) }

  let(:record) { FactoryGirl.create(:term_record, collection: person_collection) }

  let(:valid_attributes) {{ english: "Test", french: "test", spanish: "TEST", source: "A SOURCE", domain: "A DOMAIN" }}

	describe "GET new" do
		it "redirects if user not logged in" do
			get :new, { user_id: person.id, collection_id: person_collection.id }
			expect(response).to redirect_to("/login")
		end

		it "assigns a new term record as @record" do
		  login_user(person)
		  get :new, { user_id: person.id, collection_id: person_collection.id }
		  assigns(:term_record).should be_a_new(TermRecord)
		end
	end

	describe "POST create" do
		it "redirects if user not logged in" do
			post :create, { user_id: person.id, collection_id: person_collection.id, term_record: valid_attributes }
			expect(response).to redirect_to("/login")
		end

		context "with valid params" do
			before(:each) { login_user(person) }

			it "assigns the record to the active collection" do
				post :create, { user_id: person.id, collection_id: person_collection.id, term_record: valid_attributes }

				assigns(:term_record).collection_id.should eq(person_collection.id)
			end

			it "does not duplicate existing domains" do
				domain = FactoryGirl.create(:domain, name: "Greetings", user_id: person.id)

					expect {
						post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "Common knowledge" }
						}.not_to change(Domain, :count)
			end

			it "adds domain id for existing domains" do
				domain = FactoryGirl.create(:domain, name: "Greetings", user_id: person.id)

				post :create, { user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "Common knowledge" } }

				assigns(:term_record).domain_id.should eq(domain.id)
			end

			it "creates nonexisting domains" do
					expect {
						post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "New-domain-name", source: "Common knowledge" }
						}.to change(Domain, :count).by(1)
			end

			it "assigns newly created domains to term record" do
				name = "Also a new domain"
				post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: name, source: "Common knowledge" }
				assigns(:term_record).domain.name.should eq(name)
			end

			it "adds source id for existing sources" do
				source = FactoryGirl.create(:source, name: "Common knowledge", user_id: person.id)

				post :create, { user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "Common knowledge" } }

				assigns(:term_record).source_id.should eq(source.id)
			end

			it "does not duplicate existing source" do
				source = FactoryGirl.create(:source, name: "Common knowledge", user_id: person.id)

					expect {
						post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "Common knowledge" }
						}.not_to change(Source, :count)
			end

			it "creates nonexisting sources" do
					expect {
						post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "A novel source" }
						}.to change(Source, :count).by(1)
			end

			it "assigns newly created sources to term record" do
				name = "Also a new source"
				post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: name }
				assigns(:term_record).source.name.should eq(name)
			end

			it "creates a new term record" do
			  expect {
			  	post :create, user_id: person.id, collection_id: person_collection.id, term_record: valid_attributes
			  }.to change(TermRecord, :count).by(1)
			end

			it "redirects to the parent collection" do
			  post :create, user_id: person.id, collection_id: person_collection.id, term_record: valid_attributes

			  expect(response).to redirect_to("/users/#{person.id}/collections/#{person_collection.id}")
			end
		end

		context "with invalid params" do
			before(:each) { login_user(person) }

			it "assigns a newly created but unsaved record as @term_record" do
			  TermRecord.any_instance.stub(:save).and_return(false)
			  post :create, user_id: person.id, collection_id: person_collection.id, term_record: { isnt: "valid" }
			  assigns(:term_record).should be_a_new(TermRecord)
			end

			it "does not set blank domains" do
			  post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "", source: "Common knowledge" }
			  assigns(:term_record).domain_id.should be_nil
			end

			it "does not save records with blank domains" do
			  expect {
				  post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "", source: "Common knowledge" }
				  }.not_to change(TermRecord, :count)
			end

			it "does not set blank sources" do
			  post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "" }
			  assigns(:term_record).source_id.should be_nil
			end

			it "does not save records with blank sources" do
			  expect {
				  post :create, user_id: person.id, collection_id: person_collection.id, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "" }
				  }.not_to change(TermRecord, :count)
			end

			it "re-renders the 'new' template" do
			  TermRecord.any_instance.stub(:save).and_return(false)
			  post :create, user_id: person.id, collection_id: person_collection.id, term_record: { isnt: "valid" }
			  expect(response).to render_template("new")
			end
		end
	end

	describe "GET edit" do
		context "when not logged in" do
			it "redirects to the login page" do
			  get :edit, { user_id: person.id, collection_id: person_collection.id, id: record.id }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "sets @term_record to the requested record" do
			  get :edit, { user_id: person.id, collection_id: person_collection.id, id: record.id }
			  assigns(:term_record).should eq(record)
			end

			it "renders the edit view" do
			  get :edit, { user_id: person.id, collection_id: person_collection.id, id: record.id }
			  expect(response.status).to eq(200)
			end
		end
	end

	describe "PUT update" do
		context "when not logged in" do
			it "redirects to the login page" do
			  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			describe "with valid params" do

				it "locates the correct record" do
				  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id, term_record: { english: "Good day", domain: "Travel" } }
				  assigns(:term_record).should eq(record)
				end

				it "redirects to the parent collection" do
				  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id, term_record: { english: "Good day", domain: "Travel" } }
				  expect(response).to redirect_to("/users/#{person.id}/collections/#{person_collection.id}")
				end

				it "updates the correct record" do
				  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id, term_record: { english: "Good day" } }
				  record.reload
				  expect(record.english).to eq("Good day")
				end

				it "updates a domain" do
				  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id, term_record: { domain: "Travel" } }
				  record.reload
				  expect(record.domain.name).to eq("Travel")
				end

				it "updates a source" do
				  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id, term_record: { source: "Teacher" } }
				  record.reload
				  expect(record.source.name).to eq("Teacher")
				end

				it "updates diverse fields" do
				  put :update, { user_id: person.id, collection_id: person_collection.id, id: record.id, term_record: { english: "Good day", domain: "Travel" } }
				  record.reload
				  expect(record.domain.name).to eq("Travel")
				  expect(record.english).to eq("Good day")
				end
			end
		end
	end
end
