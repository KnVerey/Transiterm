class DomainsController < ApplicationController
  def index
    respond_to do |format|
      format.json { render json: current_user.domains.where("name iLIKE ?", "%#{params[:filter]}%").map(&:name) }
    end
  end
end
