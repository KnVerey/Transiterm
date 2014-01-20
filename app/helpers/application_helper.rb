module ApplicationHelper

	def format_active_langs
		current_user.active_languages.map{ |l| l.capitalize }.join("-")
	end

	def render_markdown(content)
		renderer = Redcarpet::Render::HTML.new(render_options = {
				filter_html: true,
		    no_images: true,
		    hard_wrap: true,
		    safe_links_only: true
		  })

		options = {
			autolink: true,
	    strikethrough: true,
	    superscript: true,
	    underline: true,
	    highlight: true,
	    space_after_headers: true
		  }

	  markdown = Redcarpet::Markdown.new(renderer, options)
	  markdown.render(content).html_safe
	end
end
