class CollectionsController < ApplicationController
	before_action :set_user

	def index
		@collections = @user.collections
	end

	def show
		@collection = params[:id]
	end

	def new
		@collection = Collection.new
	end

	def create
		@collection = Collection.new(collection_params)

    if @collection.save
      redirect_to user_collections_path(@user), flash: { success: 'Collection created'}
    else
      render action: 'new'
    end
	end

	def edit
	end

	def update

	end

	def destroy

	end

	private
	def set_user
		@user = current_user
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end
end
