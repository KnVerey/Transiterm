class PagesController < ApplicationController

	def home
		redirect_to collections_path if current_user
	end
end
