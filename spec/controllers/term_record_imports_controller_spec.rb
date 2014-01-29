require 'spec_helper'

describe TermRecordImportsController do

  let(:person) { FactoryGirl.create(:active_user) }

	describe "GET new" do
		context "when not logged in" do
			it "redirects to login"
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "assigns a new import as @import"
			it "assigns all user's collections as @collections"
		end
	end

	describe "POST preview" do
		context "when not logged in" do
			it "redirects to login"
		end

		context "when logged in" do
			before(:each) { login_user(person) }

			it "sets @term_records to succeeded records"
			it "sets @errors to validation error messages"
			it "assigns @confirmation"
			it "renders a preview view"
		end
	end

	describe "POST create" do
		context "when not logged in" do
			it "redirects to login"
		end

		context "when logged in" do
			before(:each) { login_user(person) }
				it "processes the import"
				it "redirects to the show view"
		end
	end

	describe "GET show" do
		context "when not logged in" do
			it "redirects to login"
		end

		context "when logged in" do
			before(:each) { login_user(person) }
				it "sets @term_records to those successfully created"
				it "sets @failures to the spreadsheet rows that failed"
		end
	end
end
