class SimplifiedBookkeepingsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :create, :update, :destroy, :confirm]
  
  def index
    return head :ok if params[:account_classification_name].blank?
    render json: { simplified_bookkeepings: @declare_user.simplified_bookkeepings.where(account_classification_name: params[:account_classification_name]) }, status: :ok
  end

  private

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by!(declare_tax_type: "income")
  end
end
