class DeclareUsersController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:show, :update, :destroy, :additional_deduction, :status]

  def show
    render json: { declare_user: json_object }, status: :ok
  end

  def create
    @declare_user = DeclareUser.new(declare_user_params)
    @declare_user.declare_tax_type = "income"
    @declare_user.user_id = @current_user.id
    @declare_user.status = DeclareUser.statuses["user"]
    @declare_user.hometax_account = @current_user.hometax_account
    if @declare_user.save
      business = Snowdon::Business.find_by(public_id: @declare_user.user.user_providers.cashnote.uid)
      simplified_bookkeepings = business.calculate(@declare_user.id)
      SimplifiedBookkeeping.upsert(rows: simplified_bookkeepings)
      render json: { declare_user: json_object }, status: :created
    else
      render json: { errors: errors_json(@declare_user.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @declare_user.update(declare_user_params)
      render json: { declare_user: json_object }, status: :ok
    else
      render json: { errors: errors_json(@declare_user.errors) }, status: :unprocessable_entity
    end
  end

  def destroy
    return render json: { errors: "unauthorized" }, status: :unauthorized if @declare_user.blank? && Rails.env.development?
    if @declare_user.destroy
      head :ok
    else
      render json: { errors: errors_json(@declare_user.errors) }, status: :unprocessable_entity
    end
  end

  def additional_deduction
    render json: {
                  applicable_single_parent: @declare_user.applicable_single_parent?,
                  applicable_woman_deduction: @declare_user.applicable_woman_deduction?,
                  applicable_woman_deduction: @declare_user.applicable_woman_deduction?
                 }, status: :ok
  end

  def status
    if @declare_user.update(status: params[:status])
      render json: { declare_user: json_object }, status: :ok
    else
      render json: { errors: errors_json(@declare_user.errors) }, status: :unprocessable_entity
    end
  end

  private

  def declare_user_params
    params.permit(:name, :residence_number, :address, :declare_tax_type, :disabled, :single_parent, :woman_deduction, :status)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user.find(params[:id])
  end

  def json_object
    @declare_user.as_json(only: DeclareUser::JSON_FIELD)
  end
end
