class PagesController < ApplicationController

	skip_before_filter :require_login

	def home
		redirect_to query_path if current_user
	end

	def msaccess
	end

  def support
  end

  def about
  end
end
