class ExcelImport
  extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations

	validates :file, presence: { message: "must be selected using the 'Choose File' button" }
	validate :correct_file_extension

	attr_reader :file

	def persisted?
	  false
  end

  def initialize(file: nil)
  	@file = file
  end

  def correct_file_extension
  	errors.add(:file, "must be an Excel file (.xls or .xlsx)") unless @file.original_filename.match(/\.xlsx?\z/)
  end
end
