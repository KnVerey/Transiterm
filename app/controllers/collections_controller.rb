class CollectionsController < ApplicationController
	before_action :set_user
	before_action :find_collection, only: [:update, :edit, :show, :destroy]

	def index
		if Collection::LANGUAGES.include?(params[:lang_toggle])
			current_user.toggle_language(params[:lang_toggle])
			current_user.save
		end

		@collections = Collection.where("user_id = '#{current_user.id}' AND english = '#{current_user.english_active}' AND french = '#{current_user.french_active}' AND spanish = '#{current_user.spanish_active}'")

		if params[:field].present? &&
			TermRecord.column_names.include?(params[:field].downcase)
			search_field = params[:field].downcase
			params[:search].gsub!("*","%")
			params[:search].prepend("%") << "%" unless params[:exact_match].to_i == 1
		else
			params[:search] = "%"
			search_field = "English"
		end

		@term_records = TermRecord.find_by_sql(["
			SELECT collections.title, term_records.*
			FROM term_records
			INNER JOIN collections ON term_records.collection_id = collections.id
			WHERE collections.user_id = '#{current_user.id}' AND collections.english = '#{current_user.english_active}' AND collections.french = '#{current_user.french_active}' AND collections.spanish = '#{current_user.spanish_active}' AND term_records.#{search_field} ilike ? LIMIT 20", "#{params[:search]}"])

		@columns = current_user.active_languages
		@fields = (current_user.active_languages + Collection::FIELDS).sort.map(&:capitalize)
	end

	def show
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
	def find_collection
		@collection = Collection.find(params[:id])
	end

	def collection_params
		params.require(:collection).permit(:title, :description, :english, :french, :spanish)
	end
end
