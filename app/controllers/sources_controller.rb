class SourcesController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json: current_user.sources.where("name iLIKE ?", "%#{params[:filter]}%").map(&:name) }
    end
  end
end
