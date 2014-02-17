class ExcelImportsController < ApplicationController
	def new
		@importer = ExcelImport.new
	end

	def create
		@importer = ExcelImport.new(file: excel_file_param, user: current_user)
		if @importer.valid? && @importer.save_records
			@saved_records = @importer.collection.term_records
			@failed_records = @importer.failed_records
			render action: 'show'
		else
			render action: 'new'
		end
	end

	def show
	end

	private
	def excel_file_param
		params[:excel_import] ? params[:excel_import][:excel_file] : nil
	end
end
