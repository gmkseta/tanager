class BusinessExpensesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :classifications, :create, :update, :destroy, :confirm]
  before_action :set_business_expense, only: [:show, :update, :destroy]
  

  def index
    return head :unprocessable_entity if params[:expense_classification_id].blank?
    @business_expenses = @declare_user.business_expenses
                                .where(expense_classification_id: params[:expense_classification_id])
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: { business_expenses: @business_expenses }, status: :ok
  end

  def classifications
    @classifications = Classification.with_amount(Classification.business_expenses.as_json, @declare_user.business_expenses.group(:expense_classification_id).sum(:amount))
    render json: { classifications: @classifications }, status: :ok
  end

  def create
    @business_expense = BusinessExpense.new(business_expense_params)
    @business_expense.declare_user_id = @declare_user.id
    if @business_expense.save
      render json: { business_expense: @business_expense }, status: :created
    else
      render json: { errors: @business_expense.errors.as_json }, status: :unprocessable_entity
    end
  end

  def update
    if @business_expense.update(business_expense_params)
      render json: { business_expense: @business_expense }, status: :ok
    else
      render json: { errors: @business_expense.errors.as_json }, status: :unprocessable_entity
    end
  end

  def destroy
    if @business_expense.destroy
      render json: { business_expense: @business_expense }, status: :ok
    else
      render json: { errors: @business_expense.errors.as_json }, status: :unprocessable_entity
    end
  end

  private

  def business_expense_params
    params.permit(:expense_classification_id, :amount, :memo, :account_classification_id, :vendor_name, :vendor_registration_number)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by!(declare_tax_type: "income")
  end

  def set_business_expense
    @business_expense = BusinessExpense.find_by!(id: params[:id], declare_user_id: @declare_user.id)
  end
end
