require 'spec_helper'

describe TermRecordsController do

  let(:person) { FactoryGirl.create(:active_user) }

  let(:person_collection) { FactoryGirl.create(:three_lang_collection, user: person) }

  let(:record) { FactoryGirl.create(:term_record, collection: person_collection) }

  let(:valid_attributes) {{ english: "Test", french: "test", spanish: "TEST", source_name: "A SOURCE", domain_name: "A DOMAIN", collection_id: person_collection.id }}

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
				t = FactoryGirl.create(:term_record)
				t.collection = a
				t.save

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

			it "will raise an error if attempting to save in someone else's collection" do
				collection = FactoryGirl.create(:collection)
				expect {
					post :create, { term_record: { english: "Test", french: "test", spanish: "TEST", source_name: "A SOURCE", domain_name: "A DOMAIN", collection_id: collection.id } }
				}.to raise_error(ActiveRecord::RecordNotFound)
			end

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
							post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "New-domain-name", source_name: "Common knowledge", collection_id: person_collection.id }
							}.to change(Domain, :count).by(1)
				end

				it "assigns newly created domains to term record" do
					name = "Also a new domain"
					post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: name, source_name: "Common knowledge", collection_id: person_collection.id }
					assigns(:term_record).domain.name.should eq(name)
				end

				it "adds source id for existing sources" do
					source = FactoryGirl.create(:source, name: "Common knowledge", user_id: person.id)

					post :create, { term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Greetings", source_name: "Common knowledge", collection_id: person_collection.id } }

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
					assigns(:term_record).source.name.should eq(valid_attributes[:source_name])
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
					post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "", source_name: "Common knowledge", collection_id: person_collection.id }
				  expect(assigns(:term_record)).to be_a_new(TermRecord)
				end

				it "does not create blank domains" do
				  expect { post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "", source_name: "Common knowledge", collection_id: person_collection.id }
				  }.not_to change(Domain, :count)
				end

				it "does not create blank sources" do
				  expect { post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Something", source_name: "", collection_id: person_collection.id }
				  }.not_to change(Source, :count)
				end

				it "does not save records with blank domains" do
				  expect {
					  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "", source_name: "Common knowledge", collection_id: person_collection.id }
					  }.not_to change(TermRecord, :count)
				end

				it "does not set blank domains" do
				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "", source_name: "Something", collection_id: person_collection.id }
				  assigns(:term_record).domain_id.should be_nil
				end

				it "does not set blank sources" do
				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Greetings", source_name: "", collection_id: person_collection.id }
				  assigns(:term_record).source_id.should be_nil
				end

				it "does not save records with blank sources" do
				  expect {
					  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Greetings", source_name: "", collection_id: person_collection.id }
					  }.not_to change(TermRecord, :count)
				end

				it "sets @collections" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)

				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Greetings", source_name: "", collection_id: person_collection.id }
				  expect(assigns(:collections)).not_to be_nil
				end

				it "sets @default_collection" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)
					person.spanish_active = true

					person_collection.reload
				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Greetings", source_name: "", collection_id: person_collection.id }
				  expect(assigns(:default_collection)).not_to be_nil
				end

				it "re-renders the 'new' template" do
				  post :create, term_record: { english: "Hello", french: "Bonjour", spanish: "Hola", domain_name: "Greetings", source_name: "", collection_id: person_collection.id }
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
				controller.stub(:current_user).and_return(record.user)
			  get :edit, { id: record.id }
			  expect(assigns(:term_record)).to eq(record)
			end

			it "raises an error if the parent collection does not belong to the user" do
				f_collection = FactoryGirl.create(:collection)
				f_record = FactoryGirl.create(:term_record, collection: f_collection)

				expect {
					get :edit, { id: f_record.id }
				}.to raise_error(ActiveRecord::RecordNotFound)
			end

			it "assigns @collections" do
				controller.stub(:current_user).and_return(record.user)
				get :edit, { id: record.id }
				expect(assigns(:collections)).not_to be_nil
			end

			it "sets @default_collection to the record's current collection" do
				controller.stub(:current_user).and_return(record.user)
			  get :edit, { id: record.id }
			  expect(assigns(:default_collection)).to eq(record.collection)
			end

			it "renders the edit view" do
				controller.stub(:current_user).and_return(record.user)
			  get :edit, { collection_id: person_collection.id, id: record.id }
			  expect(response.status).to eq(200)
			end
		end
	end

	describe "PUT update" do
		context "when not logged in" do
			it "redirects to the login page" do
			  put :update, { id: record.id }
			  expect(response).to redirect_to("/login")
			end
		end

		context "when logged in" do
			before(:each) { login_user(person) }
			before(:each) { controller.stub(:current_user).and_return(record.user) }

			context "with valid params" do

				it "assigns @term_record" do
				  put :update, { id: record.id, term_record: { collection_id: record.collection_id, english: record.english, domain_name: "Travel" } }
				  expect(assigns(:term_record)).not_to be_nil
				end

				it "raises an error if parent collection does not belong to user" do
					f_collection = FactoryGirl.create(:collection)
					f_record = FactoryGirl.create(:term_record, collection: f_collection)
					TermRecord.stub(:find).and_return(f_record)

					expect {
						put :update, { collection_id: f_collection, id: f_record.id, term_record: { english: "changeme" }}
						}.to raise_error(ActiveRecord::RecordNotFound)
				end

				it "redirects to the parent collection" do
				  put :update, { id: record.id, term_record: { collection_id: record.collection_id, english: "Good day", domain_name: "Travel" } }
				  expect(response).to redirect_to("/query")
				end

				it "updates a domain" do
				  put :update, { id: record.id, term_record: { collection_id: record.collection.id, domain_name: "Travel" } }
				  record.reload
				  expect(record.domain.name).to eq("Travel")
				end

				it "updates a source" do
				  put :update, { id: record.id, term_record: { collection_id: record.collection.id, source_name: "Teacher" } }
				  record.reload
				  expect(record.source.name).to eq("Teacher")
				end

				it "updates diverse fields" do
				  put :update, { id: record.id, term_record: { collection_id: record.collection.id, english: "Good day", domain_name: "Travel" } }
				  record.reload
				  expect(record.domain.name).to eq("Travel")
				  expect(record.english).to eq("Good day")
				end
			end

			context "with invalid params" do
				it "re-renders the 'edit' template" do
					put :update, { id: record.id, term_record: { collection_id: person_collection.id, english: "" }}
					expect(response).to render_template("edit")
				end

				it "does not update the record" do
					put :update, { id: record.id, term_record: { collection_id: person_collection.id, french: "salut", english: "" }}
					record.reload
				  expect(record.french).not_to eq("salut")
				end

				it "re-renders edit template if blank domain submitted" do
					put :update, { id: record.id, term_record: { collection_id: person_collection.id, domain_name: ""}}
					expect(response).to render_template("edit")
				end

				it "re-renders the edit template if blank source submitted" do
					put :update, { id: record.id, term_record: { collection_id: person_collection.id, source_name: ""}}
					expect(response).to render_template("edit")
				end

				it "re-renders edit if blank source submitted with other valid params" do
					put :update, { id: record.id, term_record: { collection_id: person_collection.id, source_name: "", english: "Good day"}}
					expect(response).to render_template("edit")
				end

				it "sets @collections" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)

					put :update, { id: record.id, term_record: { collection_id: person_collection.id, source_name: "", english: "Good day"}}
				  expect(assigns(:collections)).not_to be_nil
				end

				it "sets @default_collection" do
					TermRecord.any_instance.stub(:save).and_return(false)
					controller.stub(:current_user).and_return(person)
					person_collection.reload

					put :update, { id: record.id, term_record: { collection_id: person_collection.id, source_name: "", english: "Good day"}}
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

			it "raises an error if record does not belong to user" do
				f_collection = FactoryGirl.create(:collection)
				f_record = FactoryGirl.create(:term_record, collection: f_collection)
				TermRecord.stub(:find).and_return(f_record)

				expect {
					delete :destroy, { collection_id: f_collection.id, id: f_record.id }
				}.to raise_error(ActiveRecord::RecordNotFound)
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
