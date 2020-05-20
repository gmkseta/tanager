class AuthController < ApplicationController
  def status
    if token.blank?
      SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} ⚠️*세금신고오류* 신고불가: 토큰 전달안됨", channel: "#tax-ops")
      return render json: { errors: "jwt not available" }, status: :unauthorized
    end
    owner = ValidateOwner.call(token: token)
    if owner.blank?
      SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} ⚠️*세금신고오류* 신고불가: 캐시노트 유저 확인 불가", channel: "#tax-ops")
      Rails.logger.info "Not found user token: #{token}"
      return render json: { errors: "Not found user" }, status: :not_found
    end
    user = User.find_by(owner_id: owner.id)
    if user && !user.declare_user.nil?
      if ["payment", "declare"].any?(user.declare_user.status)
        status = RequestIndividualTaxReturn.call(token: user.token)
        user.declare_user.update!(status: status) if status
      end
      return render json: {
        declare_user: user.declare_user.as_json(except: DeclareUser::EXCEPT_JSON_FIELD, methods: [:hometax_address]),
        jwt: user.jwt.token,
        status: user.declare_user.status
      }, status: :ok
    end
    user ||= CreateUser.call(owner: owner, token: token)
    return render json: { errors: "Not found hometax businesses" }, status: :not_found if !user
    hometax_individual_incomes = HometaxIndividualIncome.where(owner_id: user.owner_id)
    if hometax_individual_incomes.blank?
      SlackBot.ping("#{Rails.env.development? ? "[테스트] " : ""} ⚠️*세금신고오류* #{user.name}님 - 신고불가: 홈택스 종소세 안내문 없음", channel: "#tax-ops")
      user.destroy
      return render json: { errors: "hometax not available" }, status: :not_found
    else
      declare_user = CreateDeclareUser.call(
        user,
        validate: false,
        name: hometax_individual_incomes.last.name,
        hometax_account: hometax_individual_incomes.last.hometax_account,
      )
      render json: {
        status: "empty",
        declare_user: declare_user.as_json(except: DeclareUser::EXCEPT_JSON_FIELD, methods: [:hometax_address]),
        jwt: user.jwt.token
      }, status: :ok
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
