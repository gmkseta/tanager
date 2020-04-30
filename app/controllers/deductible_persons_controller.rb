  class DeductiblePersonsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :create, :update, :destroy, :confirm]
  before_action :set_deductible_person, only: [:update, :destroy]

  def index
    @deductible_persons = DeductiblePerson.where(declare_user_id: @declare_user.id)
    render json: { deductible_people: @deductible_persons }, status: :ok
  end

  def classifications
    @classifications = Classification.relations
    render json: { relations: @classifications.as_json }, status: :ok
  end

  def create
    @deductible_person = DeductiblePerson.new(deductible_person_params)
    @deductible_person.declare_user_id = @declare_user.id
    if @deductible_person.save
      render json: { deductible_person: json_object }, status: :created
    else
      render json: { errors: @deductible_person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @deductible_person.update(deductible_person_params)
      render json: { deductible_person: json_object }, status: :ok
    else
      render json: { deductible_person: @deductible_person.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  end

  def destroy
    if @deductible_person.destroy
      render json: { deductible_person: json_object }, status: :ok
    else
      render json: { deductible_person: @deductible_person.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  end

  def confirm
    if @declare_user.update(status: "deductible_persons")
      render json: { status: @declare_user.status }, status: :ok
    else
      render json: { errors: @declare_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def deductible_person_params
    params.permit(:name, :residence_number, :address, :disabled, :classification_id, :single_parent, :woman_deduction)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by(declare_tax_type: "income")
  end

  def set_deductible_person
    @deductible_person = DeductiblePerson.find_by!(id: params[:id], declare_user_id: @declare_user.id)
  end

  def json_object
    @deductible_person.as_json(only: [:id, :name, :relation, :address, :phone_number, :residence_number])
  end
end
