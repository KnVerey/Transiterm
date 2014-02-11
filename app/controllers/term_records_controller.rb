class TermRecordsController < ApplicationController

	before_action :find_term_record, only: [:edit, :update, :destroy]
	before_action :set_collections_and_default, except: [:destroy]

	def new
		@term_record = TermRecord.new
	end

	def create
		@term_record = TermRecord.new(term_record_params)
		@term_record.collection = current_user.collections.find(params[:term_record][:collection_id])

		if @term_record.save
			redirect_to query_path, flash: { success: 'Record created'}
		else
			render action: "new"
		end
	end

	def edit
	end

	def update
		@term_record.collection = current_user.collections.find(params[:term_record][:collection_id])
		if @term_record.update(term_record_params)
			redirect_to query_path, flash: { success: 'Record updated'}
		else
			render action: "edit"
		end
	end

	def destroy
		if @term_record.destroy
			redirect_to query_path, flash: { success: 'Record deleted' }
		else
			redirect_to query_path, flash: { alert: 'Error: record not deleted' }
		end
	end


	private

	def term_record_params
		params.require(:term_record).permit(:english, :french, :spanish, :context, :comment, :domain_name, :source_name)
	end

	def find_term_record
		@term_record = current_user.term_records.find(params[:id])
	end

	def set_collections_and_default
		@collections = Collection.currently_visible(current_user)
		@default_collection = @term_record ? @term_record.collection : @collections.unscoped.order(updated_at: :desc).first
	end
end
