  class DeductiblePersonsController < ApplicationController
  before_action :authorize_request
  before_action :set_declare_user, only: [:index, :create, :update, :destroy]
  before_action :set_deductible_person, only: [:update, :destroy]

  def index
    @deductible_persons = DeductiblePerson.where(declare_user_id: @declare_user.id)
    render json: { deductible_persons: @deductible_persons.as_json(method: [:relation_name]) }, status: :ok
  end

  def classifications
    @classifications = Classification.relations
    render json: { relations: @classifications.as_json(method: [:relation_name])) }, status: :ok
  end

  def create
    @deductible_person = DeductiblePerson.new(deductible_person_params)
    @deductible_person.declare_user_id = @declare_user.id
    if @deductible_person.save
      render json: { deductible_person: @deductible_person.as_json(method: [:relation_name]) }, status: :created
    else
      render json: { errors: errors_json(@deductible_person.errors) }, status: :unprocessable_entity
    end
  end

  def update
    if @deductible_person.update(deductible_person_params)
      render json: { deductible_person: @deductible_person.as_json(method: [:relation_name]) }, status: :ok
    else
      render json: { errors: errors_json(@deductible_person.errors) }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  end

  def destroy
    if @deductible_person.destroy
      render json: { deductible_person: @deductible_person.as_json(method: [:relation_name]) }, status: :ok
    else
      render json: { errors: errors_json(@deductible_person.errors) }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound => e
    render json: { errors: e.message }, status: :unauthorized
  end

  private

  def deductible_person_params
    params.permit(:name, :residence_number, :address, :disabled, :classification_id, :single_parent, :woman_deduction)
  end

  def set_deductible_person
    @deductible_person = DeductiblePerson.find_by!(id: params[:id], declare_user_id: @declare_user.id)
  end
end
