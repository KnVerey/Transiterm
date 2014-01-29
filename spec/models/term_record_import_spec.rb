require 'spec_helper'

describe TermRecordImport do
  describe "#initialize" do
  	it "saves the target collection id"
  	it "saves the source file with a unique name"
  	it "saves the url of the source file"
  end

  describe "#preview" do
 		it "attempts to create first 5 objects from spreadsheet"
  	it "returns a hash with succeeded objects under [:records]"
  	it "returns a hash with validation messages under [:errors]"
  end

  describe "#save_records" do
  	it "persists the records to the database"
  	it "provides a list of records that failed to save"
  	it "saves the number of records succeeded"
  	it "saves the number of records failed"
  	it "saves hash of failed spreadsheet rows(?)"
  end

  describe "#cleanup" do
  	it "deletes the source file"
  end
end
