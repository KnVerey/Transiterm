class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :require_login

  private
	def not_authenticated
	  redirect_to login_path, flash: { notice: "Please log in first" }
	end

	def user_is_creator?(object)
		if object.respond_to?(:user_id)
			object.user_id == current_user.id
		elsif object.is_a? TermRecord
			object.collection.user_id == current_user.id
		end
	end
end
