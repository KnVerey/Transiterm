module ApplicationHelper

	def format_active_langs
		current_user.active_languages.map{ |l| l.capitalize }.join("-")
	end
end
