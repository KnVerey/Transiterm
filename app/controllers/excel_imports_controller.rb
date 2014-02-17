class ExcelImportsController < ApplicationController
	def new
		@importer = ExcelImport.new
	end

	def create
		@importer = ExcelImport.new(file: excel_file_param)
		if @importer.valid? && @importer.save_records
			redirect_to edit_collection_path(@importer.collection)
		else
			render action: 'new'
		end
	end

	private
	def excel_file_param
		params[:excel_import] ? params[:excel_import][:excel_file] : nil
	end
end
