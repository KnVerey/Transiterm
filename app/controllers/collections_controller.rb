class CollectionsController < ApplicationController
	before_action :find_collection, except: [:new, :create]

	def new
		@collection = Collection.new
	end

	def create
		@collection = Collection.new(collection_params)
		@collection.user_id = current_user.id

    if @collection.save
    	current_user.active_languages = @collection.active_languages
      redirect_to query_path, flash: { success: 'Collection created'}
    else
      render action: 'new'
    end
	end

	def edit
	end

	def update
		if @collection.update(collection_params)
    	current_user.active_languages = @collection.active_languages
			redirect_to query_path, notice: 'Collection details successfully updated'
		else
			render action: 'edit'
		end
	end

	def destroy
		@collection.destroy
		redirect_to query_path
	end

	def activate_alone
		current_user.collections.visible_for_user.where.not(id: @collection.id).each(&:deactivate)
		@collection.activate
		redirect_to query_path
	end

	def toggle
		if params[:all]
			Collection.toggle_all(current_user.collections.visible_for_user)
		else
			@collection.toggle
		end
		redirect_to query_path
	end

	private

	def find_collection
		@collection = current_user.collections.find(params[:id]) if params[:id]
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end
end
