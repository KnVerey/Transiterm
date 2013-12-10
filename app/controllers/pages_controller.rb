class PagesController < ApplicationController

	skip_before_filter :require_login
	def home
		redirect_to user_collections_path(@user) if current_user
	end

	def msaccess

	end
end
