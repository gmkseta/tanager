class DeclareUsersController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:create, :update, :destroy]

  def show
    render json: json_object, status: :ok
  end

  def create
    @declare_user = DeclareUser.new(declare_user_params)
    @declare_user.residence_number = params["residence_number"]
    @declare_user.user_id = @current_user.id
    @declare_user.hometax_account = @current_user.hometax_account || "XXXXXXX"
    if @declare_user.save
      render json: { declare_user: json_object }, status: :created
    else
      render json: { errors: @declare_user.errors.full_messages }, status: :unprocessable_entity
    end    
  end

  def update
    render json: json_object, status: :ok
  end

  private
  def declare_user_params
    params.permit(:name, :residence_number, :address, :declare_tax_type, :disabled, :single_parent, :woman_deduction)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user
  end

  def json_object
    @declare_user.to_json(only: [:id, :name, :address, :phone_number])
  end
end
