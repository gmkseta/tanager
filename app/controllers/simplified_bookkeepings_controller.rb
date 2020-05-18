class SimplifiedBookkeepingsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :update, :classifications, :purchase_type, :card_purchases_approvals, :hometax_card_purchases]
  before_action :set_simplified_bookkeeping, only: [:update]
  
  def index
    return head :unprocessable_entity if params[:classification_id].blank?
    @simplified_bookkeepings = @declare_user.simplified_bookkeepings.deductibles
                                .where(classification_id: params[:classification_id])
                                .includes(:classification)
    total_amount = @simplified_bookkeepings.sum(:amount).to_i
    deductible_amount = @simplified_bookkeepings.deductibles.sum(:amount).to_i
    @simplified_bookkeepings = @simplified_bookkeepings.paginate(page: params[:page]).order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   wage_sum: @declare_user.wage_sum,
                   deductible_amount: deductible_amount,
                   total_amount: total_amount,
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
    @purchase_type_sum["CardPurchasesApproval"] ||= 0
    @purchase_type_sum["CardPurchasesApproval"] += BusinessExpense.personal_cards_sum(@declare_user.id)
    @simplifiedBookkeepings = SimplifiedBookkeeping::PURCHASE_TYPES.map {
      |p| SimplifiedBookkeeping.new(declare_user_id: @declare_user.id, purchase_type: p, amount: @purchase_type_sum[p])
    }
    render json: {
      registerd_card_this_year: @declare_user.registerd_card_this_year?,
      opened_at_this_year: @declare_user.opened_at_this_year?,
      simplified_bookkeepings: @simplifiedBookkeepings
    }, status: :ok
  end

  def card_purchases_approvals
    business_expenses_card_sum = BusinessExpense.personal_cards_sum(@declare_user.id)
    deductible_card_sum = @declare_user.simplified_bookkeepings.card_approvals.deductibles.sum(:amount).to_i
    total_card_sum = @declare_user.simplified_bookkeepings.card_approvals.sum(:amount).to_i

    @simplified_bookkeepings = SimplifiedBookkeeping.card_approvals.where(declare_user_id: @declare_user.id)
                                .paginate(page: params[:page])
                                .includes(:classification)
                                .order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   wage_sum: @declare_user.wage_sum,
                   deductible_amount: (deductible_card_sum + business_expenses_card_sum).to_i,
                   total_amount: (total_card_sum + business_expenses_card_sum).to_i,
                   simplified_bookkeepings: @simplified_bookkeepings.as_json(methods: [:classification_name, :purchase_type_name]) }, status: :ok
  end

  def hometax_card_purchases
    deductible_card_sum = @declare_user.simplified_bookkeepings.hometax_cards.deductibles.sum(:amount).to_i
    total_card_sum = @declare_user.simplified_bookkeepings.hometax_cards.sum(:amount).to_i

    @simplified_bookkeepings = SimplifiedBookkeeping.hometax_cards.where(declare_user_id: @declare_user.id)
                                .paginate(page: params[:page])
                                .includes(:classification)
                                .order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   wage_sum: @declare_user.wage_sum,
                   deductible_amount: (deductible_card_sum).to_i,
                   total_amount: (total_card_sum).to_i,
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
