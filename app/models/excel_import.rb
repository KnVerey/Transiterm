class ExcelImport
  extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations

	validates :file, presence: { message: "must be selected using the 'Choose File' button" }

	attr_reader :file

	def persisted?
	  false
  end

  def initialize(file: nil)
  	@file = file
  end
end
