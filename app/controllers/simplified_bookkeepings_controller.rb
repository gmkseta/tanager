class SimplifiedBookkeepingsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :update, :confirm, :classifications, :purchase_type, :card_purchases_approvals]
  
  def index
    return head :unprocessable_entity if params[:classification_id].blank?
    @simplified_bookkeepings = @declare_user.simplified_bookkeepings
                                .where(classification_id: params[:classification_id])
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   simplified_bookkeepings: @simplified_bookkeepings }, status: :ok
  end

  def classifications
    @classifications = Classification.with_amount(
      Classification.account_classifications.as_json,
      @declare_user.simplified_bookkeepings.group(:classification_id).sum(:amount)
    )
    render json: { classifications: @classifications }, status: :ok
  end

  def purchase_type
    @purchase_type_sum = @declare_user.simplified_bookkeepings.group(:purchase_type).sum(:amount)
    @simplifiedBookkeepings = SimplifiedBookkeeping::PURCHASE_TYPES.map {
      |p| SimplifiedBookkeeping.new(declare_user_id: @declare_user.id, purchase_type: p, amount: @purchase_type_sum[p])
    }
    render json: { simplified_bookkeepings: @simplifiedBookkeepings }, status: :ok
  end

  def card_purchases_approvals
    @simplified_bookkeepings = SimplifiedBookkeeping.card_approvals.where(declare_user_id: @declare_user.id)
                                .paginate(page: params[:page])
                                .order(amount: :desc)
    render json: { total_pages: @simplified_bookkeepings.total_pages,
                   next_page: @simplified_bookkeepings.next_page,
                   simplified_bookkeepings: @simplified_bookkeepings }, status: :ok
  end

  private

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by!(declare_tax_type: "income")
  end
end
