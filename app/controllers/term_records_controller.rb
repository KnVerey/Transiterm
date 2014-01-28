class TermRecordsController < ApplicationController

	before_action :find_term_record, only: [:edit, :update, :destroy]
	before_action :set_collections_and_default, except: [:destroy]

	def new
		@term_record = TermRecord.new
	end

	def create
		handle_domain_link
		handle_source_link

		@term_record = TermRecord.new(term_record_params)

		if user_is_owner?(@term_record.collection) && @term_record.save
			redirect_to query_path, flash: { success: 'Record created'}
		else
			render action: "new"
		end
	end

	def edit
		redirect_to query_path unless user_is_owner?(@term_record)
	end

	def update
		#use is_a? String instead of present? so will throw visible error if user attempted to set blank source/domain
		handle_domain_link if params[:term_record][:domain].is_a? String
		handle_source_link if params[:term_record][:source].is_a? String

		if user_is_owner?(@term_record) && @term_record.update(term_record_params)
			redirect_to query_path, flash: { success: 'Record updated'}
		else
			render action: "edit"
		end
	end

	def destroy
		@term_record.destroy
		redirect_to query_path, flash: { success: 'Record deleted' }
	end


	private

	def term_record_params
		params.require(:term_record).permit(:english, :french, :spanish, :context, :comment, :domain_id, :source_id, :collection_id)
	end

	def find_term_record
		@term_record = TermRecord.find(params[:id])
	end

	def set_collections_and_default
		@collections = Collection.currently_visible(current_user)
		@default_collection = @term_record ? @term_record.collection : @collections.order(updated_at: :desc).limit(1).first
	end

	def handle_domain_link
		domain = Domain.find_or_create_by(name: params["term_record"]["domain"], user_id: current_user.id)

		params[:term_record][:domain_id] = domain.id
	end

	def handle_source_link
		source = Source.find_or_create_by(name: params["term_record"]["source"], user_id: current_user.id)

		params[:term_record][:source_id] = source.id
	end
end
