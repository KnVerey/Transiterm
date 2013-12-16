class TermRecordsController < ApplicationController

	def new
		@term_record = TermRecord.new
	end

	def create
		@term_record = TermRecord.new(term_record_params)

		@collection = Collection.find(params[:collection_id])
		@term_record.collection_id = @collection.id

		domain = Domain.find_or_create_by(name: params["term_record"]["domain"], user_id: current_user.id)
		@term_record.domain_id = domain.id

		source = Source.find_or_create_by(name: params["term_record"]["source"], user_id: current_user.id)
		@term_record.source_id = source.id

		if @term_record.save
			redirect_to user_collection_path(current_user, @collection), flash: { success: 'Record created'}
		else
			render action: "new"
		end

	end

	private
	def term_record_params
		params.require(:term_record).permit(:english, :french, :spanish, :context, :comment)
	end
end
