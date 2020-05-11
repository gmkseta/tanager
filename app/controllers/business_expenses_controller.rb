class BusinessExpensesController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user
  before_action :set_business_expense, only: [:show, :update, :destroy]
  

  def index
    return head :unprocessable_entity if params[:expense_classification_id].blank?
    @business_expenses = @declare_user.business_expenses
                                .where(expense_classification_id: params[:expense_classification_id])
                                .includes(:expense_classification)
                                .includes(:account_classification)
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: {
      expense_classification_id: params[:expense_classification_id],
      total_amount: @business_expenses.sum(:amount),
      business_expenses: @business_expenses.as_json(methods: [:expense_classification_name, :account_classification_name])
    }, status: :ok
  end

  def classifications
    @classifications = Classification.with_amount(
      Classification.business_expenses.as_json,
      @declare_user.business_expenses.group(:expense_classification_id).sum(:amount),
      @declare_user.id,
    )
    render json: { classifications: @classifications }, status: :ok
  end

  def personal_cards
    @business_expenses = @declare_user.business_expenses
                                .where(expense_classification_id: Classification::PERSONAL_CARD_CLASSIFICATION_ID)
                                .includes(:expense_classification)
                                .includes(:account_classification)
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: {
      expense_classification_id: Classification::PERSONAL_CARD_CLASSIFICATION_ID,
      total_amount: @business_expenses.sum(:amount),
      business_expenses: @business_expenses.as_json(methods: [:expense_classification_name, :account_classification_name])
    }, status: :ok
  end

  def create
    @business_expense = BusinessExpense.new(business_expense_params)
    @business_expense.declare_user_id = @declare_user.id
    if @business_expense.save
      render json: { business_expense: @business_expense }, status: :created
    else
      render json: { errors: errors_json(@business_expense.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @business_expense.update(business_expense_params)
      render json: { business_expense: @business_expense }, status: :ok
    else
      render json: { errors: errors_json(@business_expense.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    if @business_expense.destroy
      render json: { business_expense: @business_expense }, status: :ok
    else
      render json: { errors: errors_json(@business_expense.errors) }, status: :unprocessable_entity
    end
  end

  private

  def business_expense_params
    params.permit(:expense_classification_id, :amount, :memo, :account_classification_id, :vendor_name, :vendor_registration_number, :issued_at)
  end

  def set_business_expense
    @business_expense = BusinessExpense.find_by!(id: params[:id], declare_user_id: @declare_user.id)
  end
end
