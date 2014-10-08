class PagesController < ApplicationController

	skip_before_filter :require_login

	def home
	end

	def features
	end

  def download
  end

  def v2
  end
end
