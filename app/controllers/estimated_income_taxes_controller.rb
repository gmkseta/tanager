class EstimatedIncomeTaxesController < ApplicationController
  before_action :authorize_cashnote_request
  def index
    if params[:owner_id].present?
      estimated_income_tax = EstimatedCalulatedIncomeTax.find_by(
        owner_id: params[:owner_id]
      )
      render json: { estimated_income_tax: estimated_income_tax&.payment_tax || 0 }, status: :ok
    end
  end
end
