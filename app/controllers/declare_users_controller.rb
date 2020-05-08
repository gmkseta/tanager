class DeclareUsersController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:show, :update, :destroy, :additional_deduction, :status]

  def show
    render json: { declare_user: json_object }, status: :ok
  end

  def create
    @declare_user = CreateDeclareUser.call(
      @current_user,
      name: declare_user_params[:name],
      residence_number: declare_user_params[:residence_number],
      address: declare_user_params[:address],
      disabled: declare_user_params[:disabled],
      single_parent: declare_user_params[:name],
      woman_deduction: declare_user_params[:woman_deduction],
      status: declare_user_params[:status],
      married: declare_user_params[:married],
    )
    if @declare_user
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
                  applicable_woman_deduction_with_husband: @declare_user.applicable_woman_deduction_with_husband?,
                  applicable_woman_deduction_without_husband: @declare_user.applicable_woman_deduction_without_husband?
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
    params.permit(:name, :residence_number, :address, :declare_tax_type, :disabled, :single_parent, :woman_deduction, :status, :married)
  end

  def set_declare_user
    @declare_user = @current_user.declare_users.find(params[:id])
  end

  def json_object
    @declare_user.as_json(except: DeclareUser::EXCEPT_JSON_FIELD)
  end
end
