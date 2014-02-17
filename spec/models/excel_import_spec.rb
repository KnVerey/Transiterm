require 'spec_helper'

describe ExcelImport do

	it "is invalid unless a file has been uploaded" do
		no_file = FactoryGirl.build(:excel_import)
		expect(no_file.valid?).to be_false
		expect(no_file.errors.full_messages).to include("File must be selected using the 'Choose File' button")
	end

	it "is invalid unless the uploaded file has the correct (.xls) extension" do
		invalid_extension = FactoryGirl.build(:invalid_file_type_excel_import)
		expect(invalid_extension.valid?).to be_false
		expect(invalid_extension.errors.full_messages).to include("File must be an Excel file (.xls) - .xlsx is not currently supported")
	end

	it "is valid if given a user and a .xls file" do
	  valid_import = FactoryGirl.build(:valid_excel_import)
	  expect(valid_import.valid?).to be_true
	end

	describe "#save_records" do

		context "when the input file is completely valid (import succeeds)" do
			let (:successful_import) { FactoryGirl.build(:valid_excel_import) }

			it "generates a new collection" do
			  successful_import.save_records
			  expect(successful_import.collection).to be_a(Collection)
			end

			it "saves term records in its collection" do
			  successful_import.save_records
				expect(successful_import.collection.term_records.count).to be > 0
			end

			it "has no failed records" do
				successful_import.save_records
				expect(successful_import.failed_records).to be_empty
			end
		end

		context "when the input file contains invalid rows (import fails)" do
			let(:doomed_import) { FactoryGirl.build(:invalid_excel_import) }

			it "does not generate a collection" do
			  expect {
			  	doomed_import.save_records
			  }.not_to change(Collection, :count)
			end

			it "does not create any term records" do
			  expect {
			  	doomed_import.save_records
			  }.not_to change(TermRecord, :count)
			end

			it "provides an array of failed records" do
				doomed_import.save_records
				expect(doomed_import.failed_records).not_to be_empty
				expect(doomed_import.failed_records[0]).to be_a(TermRecord)
			end

			it "aborts after five records fail" do
			  large_doomed_import = FactoryGirl.build(:large_invalid_excel_import)
			  large_doomed_import.save_records
			  expect(large_doomed_import.failed_records.count).to eq(5)
			end
		end
	end

end
