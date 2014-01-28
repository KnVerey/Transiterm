require 'spec_helper'

describe TermRecordsController do

  let(:person) { FactoryGirl.create(:active_user) }

  let(:person_collection) { FactoryGirl.create(:three_lang_collection, user: person) }

  let(:record) { FactoryGirl.create(:term_record, collection: person_collection) }

  let(:valid_attributes) {{ english: "Test", french: "test", spanish: "TEST", source: "A SOURCE", domain: "A DOMAIN", collection_id: person_collection.id }}

	describe "GET new" do
		context "when not logged in" do
			it "redirects if user not logged in" do
				get :new, { collection_id: person_collection.id }
				expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "assigns a new term record as @record" do
			  get :new
			  assigns(:term_record).should be_a_new(TermRecord)
			end

			it "assigns most recently modified collection as @default_collection" do
				controller.stub(:current_user).and_return(person)
				a = FactoryGirl.create(:collection, user: person)
				b = FactoryGirl.create(:collection, user: person)
				t = FactoryGirl.create(:term_record, collection: a)

				get :new
				expect(assigns(:default_collection)).to eq(a)
			end

			it "assigns @collections" do
				controller.stub(:current_user).and_return(person)
				get :new
				expect(assigns(:collections)).not_to be_nil
			end
		end
	end

	describe "POST create" do
		context "when not logged in" do
			it "redirects if user not logged in" do
				post :create, { term_record: valid_attributes }
				expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			context "with valid params" do

				it "assigns the record to the active collection" do
					post :create, { term_record: valid_attributes }

					assigns(:term_record).collection_id.should eq(person_collection.id)
				end

				it "does not duplicate existing domains" do
					domain = FactoryGirl.create(:domain, name: "A DOMAIN", user_id: person.id)

						expect {
							post :create, { term_record: valid_attributes }
							}.not_to change(Domain, :count)
				end

				it "adds domain id for existing domains" do
					domain = FactoryGirl.create(:domain, name: "A DOMAIN", user_id: person.id)

					post :create, { term_record: valid_attributes }

					assigns(:term_record).domain_id.should eq(domain.id)
				end

				it "creates nonexisting domains" do
						expect {
							post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "New-domain-name", source: "Common knowledge", collection_id: person_collection.id }
							}.to change(Domain, :count).by(1)
				end

				it "assigns newly created domains to term record" do
					name = "Also a new domain"
					post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: name, source: "Common knowledge", collection_id: person_collection.id }
					assigns(:term_record).domain.name.should eq(name)
				end

				it "adds source id for existing sources" do
					source = FactoryGirl.create(:source, name: "Common knowledge", user_id: person.id)

					post :create, { term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "Common knowledge", collection_id: person_collection.id } }

					assigns(:term_record).source_id.should eq(source.id)
				end

				it "does not duplicate existing source" do
					source = FactoryGirl.create(:source, name: "A SOURCE", user_id: person.id)

						expect {
							post :create, { term_record: valid_attributes }
							}.not_to change(Source, :count)
				end

				it "creates nonexisting sources" do
						expect {
							post :create, { term_record: valid_attributes }
							}.to change(Source, :count).by(1)
				end

				it "assigns newly created sources to term record" do
					post :create, { term_record: valid_attributes }
					assigns(:term_record).source.name.should eq(valid_attributes[:source])
				end

				it "creates a new term record" do
				  expect {
				  	post :create, term_record: valid_attributes
				  }.to change(TermRecord, :count).by(1)
				end

				it "redirects to the parent collection" do
				  post :create, term_record: valid_attributes

				  expect(response).to redirect_to("/query")
				end
			end

			context "with invalid params" do
				before(:each) { login_user(person) }

				it "assigns a newly created but unsaved record as @term_record" do
				  TermRecord.any_instance.stub(:save).and_return(false)
				  post :create, term_record: { isnt: "valid" }
				  assigns(:term_record).should be_a_new(TermRecord)
				end

				it "does not set blank domains" do
				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "", source: "Common knowledge", collection_id: person_collection.id }
				  assigns(:term_record).domain_id.should be_nil
				end

				it "does not save records with blank domains" do
				  expect {
					  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "", source: "Common knowledge", collection_id: person_collection.id }
					  }.not_to change(TermRecord, :count)
				end

				it "does not set blank sources" do
				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "", collection_id: person_collection.id }
				  assigns(:term_record).source_id.should be_nil
				end

				it "does not save records with blank sources" do
				  expect {
					  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "", collection_id: person_collection.id }
					  }.not_to change(TermRecord, :count)
				end

				it "sets @collections" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)

				  post :create, term_record: {}
				  expect(assigns(:collections)).not_to be_nil
				end

				it "sets @default_collection" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)
					person.spanish_active = true

					person_collection.reload
				  post :create, term_record: {}
				  expect(assigns(:default_collection)).not_to be_nil
				end

				it "re-renders the 'new' template" do
				  TermRecord.any_instance.stub(:save).and_return(false)
				  post :create, term_record: { isnt: "valid" }
				  expect(response).to render_template("new")
				end
			end
		end
	end

	describe "GET edit" do
		context "when not logged in" do
			it "redirects to the login page" do
			  get :edit, { collection_id: person_collection.id, id: record.id }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "sets @term_record to the requested record" do
			  get :edit, { id: record.id }
			  expect(assigns(:term_record)).to eq(record)
			end

			it "assigns @collections" do
				get :edit, { id: record.id }
				controller.stub(:current_user).and_return(person)
				expect(assigns(:collections)).not_to be_nil
			end

			it "sets @default_collection to the record's current collection" do
				controller.stub(:current_user).and_return(person)
			  get :edit, { id: record.id }
			  expect(assigns(:default_collection)).to eq(record.collection)
			end

			it "renders the edit view" do
			  get :edit, { collection_id: person_collection.id, id: record.id }
			  expect(response.status).to eq(200)
			end
		end
	end

	describe "PUT update" do
		context "when not logged in" do
			it "redirects to the login page" do
			  put :update, { collection_id: person_collection.id, id: record.id }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			context "with valid params" do

				it "locates the correct record" do
				  put :update, { collection_id: person_collection.id, id: record.id, term_record: { english: "Good day", domain: "Travel" } }
				  assigns(:term_record).should eq(record)
				end

				it "redirects to the parent collection" do
				  put :update, { collection_id: person_collection.id, id: record.id, term_record: { english: "Good day", domain: "Travel" } }
				  expect(response).to redirect_to("/query")
				end

				it "updates the correct record" do
				  put :update, { collection_id: person_collection.id, id: record.id, term_record: { english: "Good day" } }
				  record.reload
				  expect(record.english).to eq("Good day")
				end

				it "updates a domain" do
				  put :update, { collection_id: person_collection.id, id: record.id, term_record: { domain: "Travel" } }
				  record.reload
				  expect(record.domain.name).to eq("Travel")
				end

				it "updates a source" do
				  put :update, { collection_id: person_collection.id, id: record.id, term_record: { source: "Teacher" } }
				  record.reload
				  expect(record.source.name).to eq("Teacher")
				end

				it "updates diverse fields" do
				  put :update, { collection_id: person_collection.id, id: record.id, term_record: { english: "Good day", domain: "Travel" } }
				  record.reload
				  expect(record.domain.name).to eq("Travel")
				  expect(record.english).to eq("Good day")
				end
			end

			context "with invalid params" do
				it "re-renders the 'edit' template" do
					put :update, { collection_id: person_collection.id, id: record.id, term_record: { english: "" }}
					expect(response).to render_template("edit")
				end

				it "does not update the record" do
					put :update, { collection_id: person_collection.id, id: record.id, term_record: { french: "salut", english: "" }}
					record.reload
				  expect(record.french).not_to eq("salut")
				end

				it "re-renders edit template if blank domain submitted" do
					put :update, { collection_id: person_collection.id, id: record.id, term_record: { domain: ""}}
					expect(response).to render_template("edit")
				end

				it "re-renders the edit template if blank source submitted" do
					put :update, { collection_id: person_collection.id, id: record.id, term_record: { source: ""}}
					expect(response).to render_template("edit")
				end

				it "re-renders edit if blank source submitted with other valid params" do
					put :update, { collection_id: person_collection.id, id: record.id, term_record: { source: "", english: "Good day"}}
					expect(response).to render_template("edit")
				end

				it "sets @collections" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)

					put :update, { collection_id: person_collection.id, id: record.id, term_record: { source: "", english: "Good day"}}
				  expect(assigns(:collections)).not_to be_nil
				end

				it "sets @default_collection" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)
					person_collection.reload

					put :update, { collection_id: person_collection.id, id: record.id, term_record: { source: "", english: "Good day"}}
				  expect(assigns(:default_collection)).not_to be_nil
				end
			end
		end
	end

	describe "DELETE destroy" do
		context "when not logged in" do
			it "redirects to the login page" do
			  delete :destroy, { collection_id: person_collection.id, id: record.id }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "identifies the requested record" do
			  delete :destroy, { collection_id: person_collection.id, id: record.id }
			  assigns(:term_record).should eq(record)
			end

			it "destroys the requested record" do
			  record.reload
			  expect {
				  delete :destroy, { collection_id: person_collection.id, id: record.id }
			  }.to change(TermRecord, :count).by(-1)
			end

			it "does not destroy the parent collection" do
				record.reload
			  expect {
				  delete :destroy, { collection_id: person_collection.id, id: record.id }
			  }.not_to change(Collection, :count)
			end

			it "redirects to the parent collection" do
			  delete :destroy, { collection_id: person_collection.id, id: record.id }
			  expect(response).to redirect_to("/query")
			end
		end
	end
end
