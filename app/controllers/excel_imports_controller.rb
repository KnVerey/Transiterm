class ExcelImportsController < ApplicationController
	def new
		@importer = ExcelImport.new
	end

	def create
		@importer = ExcelImport.new(file: excel_file_param, user: current_user)

		if @importer.save_records
			@saved_records = @importer.collection.term_records
			render action: 'show'
		elsif @failed_records = @importer.failed_records
			render action: 'show'
		else #save_records failed because file itself was invalid
			render action: 'new'
		end
	end

	private
	def excel_file_param
		params[:excel_import] ? params[:excel_import][:excel_file] : nil
	end
end
