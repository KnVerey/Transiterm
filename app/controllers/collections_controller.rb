class CollectionsController < ApplicationController
	before_action :set_user
	before_action :find_collection, only: [:update, :edit, :show, :destroy]

	def index
		if Collection::LANGUAGES.include?(params[:lang_toggle])
			current_user.toggle_language(params[:lang_toggle])
			current_user.save
		end

		@collections = Collection.where("user_id = '#{current_user.id}' AND english = '#{current_user.english_active}' AND french = '#{current_user.french_active}' AND spanish = '#{current_user.spanish_active}'")
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
				format.html { redirect_to user_collection_path(current_user, @collection), notice: 'Collection details successfully updated' }
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
