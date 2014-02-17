class CollectionsController < ApplicationController
	before_action :find_collection, only: [:update, :edit, :destroy]

	def new
		@collection = Collection.new
	end

	def create
		@collection = Collection.new(collection_params)
		@collection.user_id = current_user.id

    if @collection.save
    	current_user.ensure_collection_displays(@collection)
      redirect_to query_path, flash: { success: 'Collection created'}
    else
      render action: 'new'
    end
	end

	def edit
	end

	def update
		if @collection.update(collection_params)
    	current_user.ensure_collection_displays(@collection)
			redirect_to query_path, notice: 'Collection details successfully updated'
		else
			render action: 'edit'
		end
	end

	def destroy
		current_user.deactivate_collection(@collection) if @collection.destroy
		redirect_to query_path
	end

	private

	def find_collection
		@collection = current_user.collections.find(params[:id])
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end
end
