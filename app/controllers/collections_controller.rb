class CollectionsController < ApplicationController
	before_action :find_collection, only: [:update, :edit, :show, :destroy]

	def index
		set_fields_and_columns
		@collections = find_relevant_collections
		@term_records = run_term_record_query
	end

	def show
		set_fields_and_columns
		@term_records = run_term_record_query
	end

	def new
		@collection = Collection.new
	end

	def create
		@collection = Collection.new(collection_params)
		@collection.user_id = current_user.id

    if @collection.save
      redirect_to user_collections_path(current_user), flash: { success: 'Collection created'}
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
	def find_relevant_collections
		return [] if current_user.collections.count == 0

		@search = Collection.search do
			all_of do
				with(:user_id, current_user.id)
				with(:french, current_user.french_active)
				with(:english, current_user.english_active)
				with(:spanish, current_user.spanish_active)
			end
		end
		@search.results
	end

	def run_term_record_query
		#Don't bother if nothing to search
		return [] unless (@collections.present? || @collection.present?)

		rel_collection_ids = @collections ? @collections.map { |c| c.id } : @collection.id
		field = (@fields.include?(params[:field]) && params[:field] != "All") ? params[:field].downcase : nil

		@search = TermRecord.search do
			keywords (params[:search] || "*"), fields: field

			all_of do
				with(:collection_id, rel_collection_ids)
				with(:user_id, current_user.id)
			end
		end

		@search.results
	end

	def find_collection
		@collection = Collection.find(params[:id])
	end

	def set_fields_and_columns
		@columns = current_user.active_languages
		@fields = (current_user.active_languages + Collection::FIELDS).sort.map(&:capitalize)
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end
end
