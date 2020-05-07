class HometaxBusinessIncomesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user

  def index
    results = @declare_user.hometax_business_incomes.group_by(&:registration_number)
    @hometax_business_incomes = results.map { |k, v| {
        business_name: results[k].first.business_name,
        registration_number: results[k].first.registration_number,
        hometax_business_incomes: results[k].map { |v| { income_type: v.income_type, income_amount: v.income_amount } }
      }
    }
    render json: @hometax_business_incomes, status: :ok
  end
end
