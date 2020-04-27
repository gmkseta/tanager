class BusinessExpensesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :create, :update, :destroy]
  before_action :set_business_expense, only: [:show, :update, :destroy]
  

  def index
    @business_expenses = BusinessExpense.where(declare_user: @declare_user)
    render json: { business_expenses: @business_expenses.as_json }, status: :ok
  end

  def classifications
    @classifications = Classification.business_expenses
    render json: { business_expenses: @classifications.as_json }, status: :ok
  end

  def create
    @business_expense = BusinessExpense.new(business_expense_params)
    @business_expense.declare_user_id = @declare_user.id
    if @business_expense.save
      render json: { business_expense: @business_expense }, status: :created
    else
      render json: { errors: @business_expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @business_expense.update(business_expense_params)
      render json: { business_expense: @business_expense }, status: :ok
    else
      render json: { errors: @business_expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @business_expense.destroy
      render json: { business_expense: @business_expense }, status: :ok
    else
      render json: { errors: @business_expense.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def business_expense_params
    params.permit(:classification_id, :amount, :memo)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by!(declare_tax_type: "income")
  end

  def set_business_expense
    @business_expense = BusinessExpense.find_by!(id: params[:id], declare_user_id: @declare_user.id)
  end
end
