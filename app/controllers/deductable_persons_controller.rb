class DeductablePersonsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :create, :update, :destroy]
  before_action :set_deductable_person, only: [:update, :destroy]

  def index
    @deductable_persons = DeductablePerson.where(declare_user_id: @declare_user.id)
    render json: { deductable_people: @deductable_persons }, status: :ok
  end

  def classifications
    @classifications = Classification.relations
    render json: { relations: @classifications.as_json }, status: :ok
  end

  def create
    @deductable_person = DeductablePerson.new(deductable_person_params)
    @deductable_person.declare_user_id = @declare_user.id
    if @deductable_person.save
      render json: { deductable_person: json_object }, status: :created
    else
      render json: { errors: @deductable_person.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @deductable_person.update(deductable_person_params)
      render json: { deductable_person: json_object }, status: :ok
    else
      render json: { deductable_person: @deductable_person.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  end

  def destroy
    if @deductable_person.destroy
      render json: { deductable_person: json_object }, status: :ok
    else
      render json: { deductable_person: @deductable_person.errors.full_messages }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  end

  private

  def deductable_person_params
    params.permit(:name, :residence_number, :address, :disabled, :classification_id, :single_parent, :woman_deduction)
  end

  def set_declare_user
    @declare_user = @current_user.declare_user.find_by(declare_tax_type: "income")
  end

  def set_deductable_person
    @deductable_person = DeductablePerson.find_by!(id: params[:id], declare_user_id: @declare_user.id)
  end

  def json_object
    @deductable_person.as_json(only: [:id, :name, :relation, :address, :phone_number, :residence_number])
  end
end
