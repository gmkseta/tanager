class ClassificationsController < ApplicationController
  def relations
    @classifications = Classification.relations
    render json: { relations: @classifications.as_json }, status: :ok
  end

  def business_expenses
    @classifications = Classification.business_expenses
    render json: { business_expenses: @classifications.as_json }, status: :ok
  end

  def account_classifications
    @classifications = Classification.account_classifications
    render json: { account_classifications: @classifications.as_json }, status: :ok
  end
end
