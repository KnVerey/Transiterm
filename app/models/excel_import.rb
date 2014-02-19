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

  	temp_records = build_records_from_excel
  	try_to_save_records(temp_records)
  end

  private
  def correct_file_extension
  	(errors.add(:file, "must be an Excel file (.xls) - .xlsx is not currently supported") unless @file.original_filename.match(/\.xls\z/)) if @file
  end

  def build_records_from_excel
  	temp_records_array = []
  	@excel.each 1 do |row|
  		break unless row.any?
  		temp_records_array << TermRecord.new(get_attributes(row))
  	end
  	temp_records_array
  end

  def get_attributes(row)
  	attributes = {}
  	attributes[:user] = @user
  	attributes[:collection] = @collection
  	@headings_map.each_key { |field| attributes[field] = row[@headings_map[field]] }
  	attributes
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

  def try_to_save_records(temp_records_array)
  	@failed_records = []
  	TermRecord.transaction do
	  	temp_records_array.each do |r|
				@failed_records << r unless r.save
				break if @failed_records.count >= 5
	  	end
	  	raise ActiveRecord::Rollback if @failed_records.present?
	  end
	  @failed_records.empty?
  end

  def map_headings
  	headings_row = @excel.row(0)
  	headings_row.inject({}) do |headings_hash, cell|
  		if cell.present? && cell.match(/\A(english|french|spanish|context|comment|domain name|source name)\z/i)
  			headings_hash[cell.downcase.gsub(" ", "_").to_sym] = headings_row.find_index(cell)
  		end
  		headings_hash
  	end
  end
end
