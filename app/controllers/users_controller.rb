class UsersController < ApplicationController
  has_secure_password
  before_action :authorize_request, except: :create
  before_action :set_user, only: [:show, :update, :destroy]

  def show
    render json: json_object(@user), status: :ok
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render json: { jwt: @user.jwt, json_object(@user) }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    render json: json_object(@user), status: :ok
  end

  private
  def user_params
    params.permit(:name, :residence_number, :address, :phone_number)
  end

  def set_user
    @user = User.find(param[:id])
  end

  def json_object
    @user.to_json(only: [:id, :name, :address, :phone_number])
  end
end
