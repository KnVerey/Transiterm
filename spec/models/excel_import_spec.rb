require 'spec_helper'

describe ExcelImport do

	it "validates that a file has been uploaded" do
		no_file = FactoryGirl.build(:excel_import)
		expect(no_file.valid?).to be_false
		expect(no_file.errors.full_messages).to include("File must be selected using the 'Choose File' button")
	end

	it "validates that the file has the correct extension" do
		invalid_extension = FactoryGirl.build(:invalid_file_type_excel_import)
		expect(invalid_extension.valid?).to be_false
		expect(invalid_extension.errors.full_messages).to include("File must be an Excel file (.xls) - .xlsx is not currently supported")
	end

end
