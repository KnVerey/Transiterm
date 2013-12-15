class CollectionsController < ApplicationController
	before_action :set_user
	before_action :find_collection, only: [:update, :edit, :show, :destroy]

	def index
		@collections = @user.collections
	end

	def show
	end

	def new
		@collection = Collection.new
	end

	def create
		@collection = Collection.new(collection_params)
		@collection.user_id = @user.id

    if @collection.save
      redirect_to user_collections_path(@user), flash: { success: 'Collection created'}
    else
      render action: 'new'
    end
	end

	def edit
	end

	def update
		respond_to do |format|
			if @collection.update(collection_params)
				format.html { redirect_to user_collections_path, notice: 'Collection details successfully updated' }
				format.json {}
			else
				format.html { render action: 'edit' }
				format.json {}
			end
		end
	end

	def destroy
		@collection.destroy
		redirect_to user_collections_path
	end

	private
	def set_user
		@user = current_user
	end

	def find_collection
		@collection = Collection.find(params[:id])
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end
end
