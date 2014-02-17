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

  def save_records
  	excel = Spreadsheet.open(@file.tempfile.path)
  	sheet = excel.worksheet 0
  	headings_map = map_headings(sheet.row(0))
  	sheet.each 1 do |row|

  	end
  end

  private
  def correct_file_extension
  	errors.add(:file, "must be an Excel file (.xls or .xlsx)") unless @file.original_filename.match(/\.xlsx?\z/)
  end

  def map_headings(row)
  	row.inject({}) do |hash, cell|
  		if cell.match(/\A(english|french|spanish|context|comment|domain|source)\z/i)
  			hash[cell.downcase] = row.find_index(cell)
  		end
  		hash
  	end
  end
end
