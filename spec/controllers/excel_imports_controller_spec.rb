require 'spec_helper'

describe ExcelImportsController do

	let(:person) { FactoryGirl.create(:active_user) }

	describe "GET new" do
		it "redirects if user not logged in" do
		  get :new
		  expect(response).to redirect_to("/login")
		end

		it "assigns a new excel import as @importer" do
			login_user(person)
		  get :new
			expect(assigns(:importer)).to be_an(ExcelImport)
		end

		it "responds with 200 status" do
		  login_user(person)
		  get :new
		  expect(response.status).to eq(200)
		end
	end

	describe "POST create" do
		it "redirects if user not logged in" do
		  post :create
		  expect(response).to redirect_to("/login")
		end

		it "assigns a new excel import as @importer with current_user as its user" do
			login_user(person)
			controller.stub(:current_user).and_return(person)
		  post :create
		  expect(assigns(:importer)).to be_an(ExcelImport)
		  expect(assigns(:importer).user).to eq(person)
		end

		context "when the file is invalid" do
			it "re-renders the 'new' template" do
				login_user(person)
				invalid_importer = FactoryGirl.build(:excel_import)
				ExcelImport.stub(:new).and_return(invalid_importer)
				ExcelImport.any_instance.stub(:valid?).and_return(false)

				post :create
				expect(response).to render_template("new")
			end
		end

		context "when the file is valid" do
			before(:each) { login_user(person) }
			before(:each) { ExcelImport.any_instance.stub(:valid?).and_return(true) }

			it "renders the 'show' template" do
				valid_import = FactoryGirl.build(:valid_excel_import)
				ExcelImport.stub(:new).and_return(valid_import)

				post :create
				expect(response).to render_template("show")
			end

			it "attempts to save records from the file" do
				valid_import = FactoryGirl.build(:valid_excel_import)
				ExcelImport.stub(:new).and_return(valid_import)

				expect(valid_import).to receive(:save_records)
				post :create
			end

			it "assigns @saved_records if import succeeded (contains term records)" do
				valid_import = FactoryGirl.build(:valid_excel_import)
				ExcelImport.stub(:new).and_return(valid_import)

				post :create
				expect(assigns(:saved_records)).to be_an(ActiveRecord::Relation)
				expect(assigns(:saved_records)[0]).to be_a(TermRecord)
			end

			it "does not assign @saved_records if the import failed" do
				invalid_import = FactoryGirl.build(:invalid_excel_import)
				ExcelImport.stub(:new).and_return(invalid_import)

				post :create
				expect(assigns(:saved_records)).to be_nil
			end

			it "does not assign @failed records if the import succeeded" do
				valid_import = FactoryGirl.build(:valid_excel_import)
				ExcelImport.stub(:new).and_return(valid_import)

				post :create
				expect(assigns(:failed_records)).to be_nil
			end

			it "assigns @failed records, which is an array of term records, if import failed" do
				invalid_import = FactoryGirl.build(:invalid_excel_import)
				ExcelImport.stub(:new).and_return(invalid_import)

				post :create
				expect(assigns(:failed_records)).to be_an(Array)
				expect(assigns(:failed_records)[0]).to be_a(TermRecord)
			end
		end
	end
end
