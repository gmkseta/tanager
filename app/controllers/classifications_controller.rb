class ClassificationsController < ApplicationController
  def relations
    @classifications = Classification.relations
    render json: { classifications: @classifications.as_json }, status: :ok
  end
end
