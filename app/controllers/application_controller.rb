class ApplicationController < ActionController::API
  include Knock::Authenticable

  def authorize_request
    begin
      @current_user = User.find(auth['sub'])
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
    @declare_user = @current_user.declare_user.find_by!(declare_tax_type: "income")
  end
end
