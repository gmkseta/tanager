class CalculatedTaxesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user
  def index    
    render json: {
      base_expense_rate: @declare_user.hometax_individual_income.base_expense_rate,
      expense_ratio: @declare_user.hometax_individual_income.expenses_ratio,
      declare_from: Date.today.last_year.beginning_of_year.strftime,
      declare_to: Date.today.last_year.end_of_year.strftime,
      declare_user: @declare_user.as_json(except: DeclareUser::EXCEPT_JSON_FIELD),
      calculated_taxes: {
        calculated_tax_by_bookkeeping: @declare_user.calculated_tax_by_bookkeeping.as_json,
        calculated_tax_by_ratio: @declare_user.calculated_tax_by_ratio.as_json,
      } 
    }, status: :ok
  end
end
