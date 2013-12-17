class TermRecordsController < ApplicationController

	before_action :find_term_record, only: [:edit, :update, :destroy]

	def new
		@term_record = TermRecord.new
	end

	def create
		handle_domain_link
		handle_source_link

		@term_record = TermRecord.new(term_record_params)

		@collection = Collection.find(params[:collection_id])
		@term_record.collection_id = @collection.id

		if @term_record.save
			redirect_to user_collection_path(current_user, @collection), flash: { success: 'Record created'}
		else
			render action: "new"
		end
	end

	def edit

	end

	def update
		handle_domain_link if params[:term_record][:domain].present?
		handle_source_link if params[:term_record][:source].present?

		if @term_record.update(term_record_params)
			redirect_to user_collection_path(current_user, @term_record.collection),flash: { success: 'Record updated'}
		else
		end
	end


	private

	def term_record_params
		params.require(:term_record).permit(:english, :french, :spanish, :context, :comment, :domain_id, :source_id)
	end

	def find_term_record
		@term_record = TermRecord.find(params[:id])
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
