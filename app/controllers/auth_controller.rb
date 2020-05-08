class AuthController < ApplicationController
  def status
    return render json: { errors: "jwt not available" }, status: :unauthorized if token.blank?
    owner = ValidateOwner.call(token: token)
    return render json: { errors: "not found user" }, status: :not_found if owner.blank?
    user = User.find_by(owner_id: owner.id)
    return render json: { declare_user: user.declare_user&.as_json(only: DeclareUser::JSON_FIELD),
                   jwt: user.jwt.token,
                   status: user.declare_users.blank? ? "empty" : user.declare_user.status
                 }, status: :ok if user
    user = CreateUser.call(owner: owner)
    render json: { status: "empty", jwt: user.jwt.token }, status: :ok if user
  end

  def destroy
    return render json: { errors: "jwt not available" }, status: :unauthorized if token.blank?
    user = User.find_by!(token: token)
    user.destroy
    render json: { status: "empty" }, status: :ok
  end

  private

  def auth_params
    params.permit(:provider, :declare_type)
  end
end
