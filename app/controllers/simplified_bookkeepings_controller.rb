class SimplifiedBookkeepingsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :update, :classifications, :purchase_type, :card_purchases_approvals]
  before_action :set_simplified_bookkeeping, only: [:update]
  
  def index
    return head :unprocessable_entity if params[:classification_id].blank?
    @simplified_bookkeepings = @declare_user.simplified_bookkeepings
                                .where(classification_id: params[:classification_id])
                                .includes(:classification)
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   total_amount: @simplified_bookkeepings.sum(:amount),
                   simplified_bookkeepings: @simplified_bookkeepings.as_json(methods: [:classification_name, :purchase_type_name]) }, status: :ok
  end

  def update
    simplified_bookkeeping = UpdateSimplifiedBookkeeping.call(
      simplified_bookkeeping: @simplified_bookkeeping,
      params: simplified_bookkeeping_params
    )
    render json: { simplified_bookkeeping: simplified_bookkeeping }, status: :ok
  end

  def classifications
    @classifications = Classification.with_amount(
      Classification.account_classifications.as_json,
      @declare_user.simplified_bookkeepings.deductibles.group(:classification_id).sum(:amount),
      @declare_user.id,
    )
    render json: { classifications: @classifications }, status: :ok
  end

  def purchase_type
    @purchase_type_sum = @declare_user.simplified_bookkeepings.deductibles.group(:purchase_type).sum(:amount)
    @purchase_type_sum["CardPurchasesApproval"] += BusinessExpense.personal_cards_sum(@declare_user.id)
    @simplifiedBookkeepings = SimplifiedBookkeeping::PURCHASE_TYPES.map {
      |p| SimplifiedBookkeeping.new(declare_user_id: @declare_user.id, purchase_type: p, amount: @purchase_type_sum[p])
    }
    render json: {
      registerd_card_this_year: @declare_user.registerd_card_this_year?,
      simplified_bookkeepings: @simplifiedBookkeepings
    }, status: :ok
  end

  def card_purchases_approvals
    @simplified_bookkeepings = SimplifiedBookkeeping.card_approvals.where(declare_user_id: @declare_user.id)
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   deductible_amount: @simplified_bookkeepings.deductibles.sum(:amount),
                   total_amount: @simplified_bookkeepings.sum(:amount) + BusinessExpense.personal_cards_sum(@declare_user.id),
                   simplified_bookkeepings: @simplified_bookkeepings.as_json(methods: [:classification_name, :purchase_type_name]) }, status: :ok
  end

  private

  def set_simplified_bookkeeping
    @simplified_bookkeeping = @declare_user.simplified_bookkeepings.find(params[:id])
  end

  def simplified_bookkeeping_params
    params.permit(:deductible, :classification_id)
  end
end
