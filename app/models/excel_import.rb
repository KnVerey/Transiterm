class ExcelImport
  extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations

	validates :file, presence: { message: "must be selected using the 'Choose File' button" }
	validate :correct_file_extension

	attr_reader :file, :collection, :failed_records

	def persisted?
	  false
  end

  def initialize(file: nil, user: nil)
  	@file = file
  	@user = user
  	@collection = Collection.new(user: user, title: "Imported Records", english: true, french: true, spanish: true)
  end

  def save_records
  	excel = Spreadsheet.open(@file.tempfile.path)
  	sheet = excel.worksheet 0
  	@headings_map = map_headings(sheet.row(0))
  	records_to_import = []

  	sheet.each 1 do |row|
  		r = TermRecord.new(get_attributes(row), user: @user, collection: @collection)
  		r.user = @user
  		r.collection = @collection
  		records_to_import << r
  	end
  	persist_records(records_to_import)
  	# must return true if saved any
  end

  private
  def correct_file_extension
  	errors.add(:file, "must be an Excel file (.xls) - .xlsx is not currently supported") unless @file.original_filename.match(/\.xlsx?\z/)
  end

  def persist_records(records_array)
  	@failed_records = []
  	records_array.each do |r|
			r.save
			@failed_records << r unless r.persisted?
  	end
  end

  def map_headings(row)
  	row.inject({}) do |hash, cell|
  		if cell.match(/\A(english|french|spanish|context|comment|domain name|source name)\z/i)
  			hash[cell.downcase.gsub(" ", "_").to_sym] = row.find_index(cell)
  		end
  		hash
  	end
  end

  def get_attributes(row)
  	attributes = @headings_map.keys.inject({}) do |attributes, field|
  		attributes[field] = row[@headings_map[field]]
  		attributes
  	end
  end
end
