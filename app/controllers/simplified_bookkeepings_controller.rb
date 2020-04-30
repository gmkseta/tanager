class SimplifiedBookkeepingsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :update, :confirm, :classifications]
  
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
    @classifications = Classification.with_amount(Classification.account_classifications.as_json, @declare_user.simplified_bookkeepings.group(:classification_id).sum(:amount))
    render json: { classifications: @classifications }, status: :ok
  end

  private

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by!(declare_tax_type: "income")
  end
end
