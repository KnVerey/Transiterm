class ExcelImport
  extend ActiveModel::Naming
	include ActiveModel::Conversion
	include ActiveModel::Validations
	def persisted?
	  false
  end

	validates :file, presence: { message: "must be selected using the 'Choose File' button" }
	validate :correct_file_extension

	attr_reader :file, :collection, :failed_records, :user

  def initialize(file: nil, user: nil)
  	@file = file
  	@user = user
  end

  def save_records
  	return unless self.valid?

  	@excel = Spreadsheet.open(@file.tempfile.path).worksheet 0
  	@headings_map = map_headings
  	@collection = initialize_import_collection

  	records_to_import = []

  	@excel.each 1 do |row|
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
  	(errors.add(:file, "must be an Excel file (.xls) - .xlsx is not currently supported") unless @file.original_filename.match(/\.xls\z/)) if @file
  end

  def initialize_import_collection
  	model_row = @excel.row(1)
  	english = lang_active?("english", model_row)
  	french = lang_active?("french", model_row)
  	spanish = lang_active?("spanish", model_row)

  	Collection.new(user: @user, title: "Imported Records", english: english, french: french, spanish: spanish)
  end

	def lang_active?(lang, model_row)
		@headings_map.has_key?(lang.to_sym) && model_row[@headings_map[lang.to_sym]].present?
  end

  def try_persist_records(records_array)
  	@failed_records = []
  	TermRecord.transaction do
	  	records_array.each do |r|
				r.save
				@failed_records << r unless r.persisted?
				break if @failed_records.count >= 5
	  	end
	  	raise ActiveRecord::Rollback if @failed_records.present?
	  end
  end

  def map_headings
  	headings_row = @excel.row(0)
  	headings_row.inject({}) do |hash, cell|
  		if cell.match(/\A(english|french|spanish|context|comment|domain name|source name)\z/i)
  			hash[cell.downcase.gsub(" ", "_").to_sym] = headings_row.find_index(cell)
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
