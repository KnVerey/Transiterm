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
  	@collection = Collection.new(user: user, title: "Imported Records")
  end

  def save_records
  	excel = Spreadsheet.open(@file.tempfile.path).worksheet 0
  	@headings_map = map_headings(excel.row(0))
  	set_collection_langs(excel.row(1))
  	records_to_import = []

  	excel.each 1 do |row|
  		break unless row.any?
  		r = TermRecord.new(get_attributes(row))
  		r.user = @user
  		r.collection = @collection
  		records_to_import << r
  	end
  	try_persist_records(records_to_import)
  end

  private
  def correct_file_extension
  	errors.add(:file, "must be an Excel file (.xls) - .xlsx is not currently supported") unless @file.original_filename.match(/\.xlsx?\z/)
  end

  def try_persist_records(records_array)
  	@failed_records = []
  	TermRecord.transaction do
	  	records_array.each do |r|
				r.save
				@failed_records << r unless r.persisted?
				break if @failed_records.count >= 10
	  	end
	  	raise ActiveRecord::Rollback if @failed_records.present?
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

	def set_collection_langs(first_row)
  	Collection::LANGUAGES.each do |lang|
  		lang_activity_state = @headings_map.has_key?(lang.to_sym) && first_row[@headings_map[lang.to_sym]].present?
  		@collection.send("#{lang}=", lang_activity_state)
  	end
  end

  def get_attributes(row)
  	attributes = @headings_map.keys.inject({}) do |attributes, field|
  		attributes[field] = row[@headings_map[field]]
  		attributes
  	end
  end
end
