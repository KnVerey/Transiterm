class ExcelImportsController < ApplicationController
	def new
		@importer = ExcelImport.new
	end
end
