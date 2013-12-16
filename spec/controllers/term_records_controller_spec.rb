require 'spec_helper'

describe TermRecordsController do

  let(:person) { FactoryGirl.create(:user, email: "email#{rand(1000)}@test.com") }

  let(:person_collection) { FactoryGirl.create(:three_lang_collection, user: person) }

  let(:record) { FactoryGirl.create(:term_record, collection: person_collection) }

  let(:valid_attributes) {{ english: "Hello", french: "Bonjour", spanish: "Hola", domain: "Greetings", source: "Common knowledge" }}

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
		end
	end
end
