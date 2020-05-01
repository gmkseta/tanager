class DeclareUsersController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:show, :update, :destroy]

  def show
    render json: { declare_user: json_object }, status: :ok
  end

  def create
    @declare_user = DeclareUser.new(declare_user_params)
    @declare_user.declare_tax_type = "income"
    @declare_user.residence_number = params["residence_number"]
    @declare_user.user_id = @current_user.id
    @declare_user.status = 1
    @declare_user.hometax_account = @current_user.hometax_account || "XXXXXXX"

    if @declare_user.save
      render json: { declare_user: json_object }, status: :created
    else
      render json: { errors: @declare_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @declare_user.update(declare_user_params)
    render json: { declare_user: json_object }, status: :ok
  end

  def destory
    return render json: { errors: "unauthorized" }, status: :unauthorized if @declare_user.id != params[:id]
    @declare_user.destroy
    head :ok
  end

  private

  def declare_user_params
    params.permit(:name, :residence_number, :address, :declare_tax_type, :disabled, :single_parent, :woman_deduction, :status)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by(declare_tax_type: "income")
  end

  def json_object
    @declare_user.as_json(only: [:id, :name, :residence_number, :address, :phone_number])
  end
end
