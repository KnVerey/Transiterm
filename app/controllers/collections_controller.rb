class CollectionsController < ApplicationController
	before_action :find_collection, only: [:update, :edit, :destroy]

	def new
		@collection = Collection.new
	end

	def create
		@collection = Collection.new(collection_params)
		@collection.user_id = current_user.id

    if @collection.save
    	current_user.toggle_collection(@collection.id)
    	current_user.french_active = @collection.french
    	current_user.english_active = @collection.english
    	current_user.spanish_active = @collection.spanish
    	current_user.save
      redirect_to query_path, flash: { success: 'Collection created'}
    else
      render action: 'new'
    end
	end

	def edit
		redirect_to query_path unless user_is_owner?(@collection)
	end

	def update
		respond_to do |format|
			if user_is_owner?(@collection) && @collection.update(collection_params)
				format.html { redirect_to query_path, notice: 'Collection details successfully updated' }
				format.json {}
			else
				format.html { render action: 'edit' }
				format.json {}
			end
		end
	end

	def destroy
		remove_from_active_ids if user_is_owner?(@collection) && @collection.destroy
		redirect_to query_path
	end

	private

	def find_collection
		@collection = Collection.find(params[:id])
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end

	def remove_from_active_ids
		if current_user.active_collection_ids.include?(@collection.id)
			current_user.active_collection_ids_will_change!
			current_user.active_collection_ids.delete(@collection.id)
			current_user.save
		end
	end
end
