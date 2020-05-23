class EstimatedIncomeTaxesController < ApplicationController
  before_action :authorize_cashnote_request
  def index
    if params[:owner_id].present?
      estimated_income_tax = EstimatedCalulatedIncomeTax.find_by(
        owner_id: params[:owner_id]
      )
      if estimated_income_tax
        render json: {
          estimated_income_tax: estimated_income_tax.payment_tax,
          available_quick_path: estimated_income_tax.payment_tax <= 1000000
        }, status: :ok
      else
        render json: {
          estimated_income_tax: nil,
          available_quick_path: false
        }, status: :ok
      end
    end
  end
end
