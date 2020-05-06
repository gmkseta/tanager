class CalculatedTaxesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user
  def index    
    render json: { calculated_taxes: {
        base_expense_rate: @declare_user.hometax_individual_income.base_expense_rate,
        calculated_tax_by_bookkeeping: @declare_user.calculated_tax_by_bookkeeping.as_json,
        calculated_tax_by_ratio: @declare_user.calculated_tax_by_ratio.as_json,
      } 
    }, status: :ok
  end
end
