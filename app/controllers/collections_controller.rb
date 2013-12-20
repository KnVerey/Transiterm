class CollectionsController < ApplicationController
	before_action :find_collection, only: [:update, :edit, :show, :destroy]

	def index
		set_fields_and_columns
		@collections = find_relevant_collections
		@term_records = run_term_record_query
	end

	def show
		set_fields_and_columns
		search_field = configure_search_params
		@term_records = TermRecord.where("collection_id = '#{@collection.id}' AND #{search_field} ilike ?", "#{params[:search]}").limit(20)
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
		Collection.where("user_id = '#{current_user.id}' AND english = '#{current_user.english_active}' AND french = '#{current_user.french_active}' AND spanish = '#{current_user.spanish_active}'")
	end

	def configure_search_params
		if params[:field].present? && @fields.include?(params[:field])

			params[:search].gsub!("*","%")
			params[:search].prepend("%") << "%" unless params[:exact_match].to_i == 1

			search_field = case
			when params[:field] == "Domain"
				"domains.name"
			when params[:field] == "Source"
				"sources.name"
			else
				"term_records.#{params[:field].downcase}"
			end

		else
			params[:search] = "%"
			search_field = "term_records.english"
		end

		return search_field
	end

	def run_term_record_query
		search_field = configure_search_params

		TermRecord.find_by_sql(["
		SELECT collections.title, term_records.*
		FROM term_records
		INNER JOIN collections ON term_records.collection_id = collections.id
		WHERE collections.user_id = '#{current_user.id}' AND collections.english = '#{current_user.english_active}' AND collections.french = '#{current_user.french_active}' AND collections.spanish = '#{current_user.spanish_active}' AND #{search_field} ilike ? LIMIT 20", "#{params[:search]}"])
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
