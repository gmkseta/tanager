class AuthController < ApplicationController
  def status
    return render json: { errors: "jwt not available" }, status: :unauthorized if token.blank?
    owner = ValidateOwner.call(token: token)
    return render json: { errors: "not found user" }, status: :not_found if owner.blank?
    user = User.find_by(owner_id: owner.id)
    return render json: { declare_user: user.declare_user&.as_json(except: DeclareUser::EXCEPT_JSON_FIELD, methods: [:hometax_address]),
                   jwt: user.jwt.token,
                   status: user.declare_users.blank? ? "empty" : user.declare_user.status
                 }, status: :ok if user
    user = CreateUser.call(owner: owner)
    hometax_individual_incomes = HometaxIndividualIncome.where(owner_id: user.owner_id)
    if hometax_individual_incomes.blank?
      SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} *세금신고오류* #{user.name}님 - 신고불가: 홈택스 데이터 없음)", channel: "#labs-ops")
      user.destroy
      return render json: { errors: "hometax not available" }, status: :not_found
    else
      declare_user = CreateDeclareUser.call(
        user,
        validate: false,
        name: hometax_individual_incomes.last.name,
        hometax_account: hometax_individual_incomes.last.hometax_account,
      )
      render json: { status: "empty", declare_user: declare_user, jwt: user.jwt.token }, status: :ok if user
    end
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
