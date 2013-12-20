class CollectionsController < ApplicationController
	before_action :set_user
	before_action :find_collection, only: [:update, :edit, :show, :destroy]

	def index
		if Collection::LANGUAGES.include?(params[:lang_toggle])
			current_user.toggle_language(params[:lang_toggle])
			current_user.save
		end

		# @collections = Collection.where("user_id = '#{current_user.id}' AND english = '#{current_user.english_active}' AND french = '#{current_user.french_active}' AND spanish = '#{current_user.spanish_active}'")

		@term_records = TermRecord.find_by_sql("
			SELECT collections.title, term_records.*
			FROM term_records
			INNER JOIN collections ON term_records.collection_id = collections.id
			WHERE collections.user_id = '#{current_user.id}' AND collections.english = '#{current_user.english_active}' AND collections.french = '#{current_user.french_active}' AND collections.spanish = '#{current_user.spanish_active}';")

		@collections = @term_records.uniq { |record| record.title  }
		@columns = current_user.active_languages
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
