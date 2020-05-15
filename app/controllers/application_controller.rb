class ApplicationController < ActionController::API
  before_action :set_raven_context
  include Knock::Authenticable

  def authorize_request
    begin
      @current_user = User.find(auth['sub'])
      Raven.user_context(id: @current_user.id) if @current_user
    rescue ActiveRecord::RecordNotFound => e
      render json: { errors: e.message }, status: :unauthorized
    rescue JWT::DecodeError => e
      render json: { errors: e.message }, status: :unauthorized
    end
  end

  def token
    token = token_from_request_headers
  end

  def auth
    Knock::AuthToken.new(token: token).payload
  end

  def errors_json(errors)
    errors.as_json.map {|k,v| {"#{k}": v[0]}}
  end

  def set_declare_user
    @declare_user = @current_user.declare_users.find_by!(declare_tax_type: "income")
  end

  def authorize_owl_request
    if request.headers["X-Tanager-Api-Key"] == Rails.application.credentials[Rails.env.to_sym].dig(:client_api_key, :owl)
      @owner_id = params[:owner_id]
    else
      render json: { errors: "unauthorized" }, status: :unauthorized
    end
  end

  def set_raven_context
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
