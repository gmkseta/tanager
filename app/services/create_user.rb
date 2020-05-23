class CreateUser < Service::Base
  option :owner
  option :token, optional: true

  def run
    user = ActiveRecord::Base.transaction do
      businesses = owner.businesses.joins(:hometax_business)
      if businesses.blank?
        SendSlackMessageJob.perform_later(
          "⚠️*종소세* #{owner.name}님 - 신고불가: 홈택스 사업장 데이터 없음)",
          "#tax-ops"
        )
        return nil
      end
      user = User.create!(
        login: owner.login || businesses.first.registration_number,
        password: owner.login || businesses.first.registration_number,
        name: owner.name || businesses.first.owner_name,
        owner_id: owner.id,
        token: token,
        hometax_address: owner.hometax_businesses.last.owner_address,
        phone_number: owner.phone.number,
      )
      businesses.each do |b|
        Business.create!(
          user_id: user.id,
          name: b.hometax_name,
          registration_number: b.registration_number,
          address: b.hometax_address,
          public_id: b.public_id,
          owner_id: owner.id,
          login: b.hometax_business.login,
          hometax_classification_name: b.hometax_business.classification_name,
          hometax_classification_code: b.hometax_business.classification_code,
          taxation_type: b.hometax_business.taxation_type,
          opened_at: b.hometax_business.opened_at,
          official_name: b.hometax_business.official_name,
          official_code: b.hometax_business.official_code,
          official_number: b.hometax_business.official_number,
          closed_at: b.closed_at,
        )
      end
      SendSlackMessageJob.perform_later(
        "*종소세* #{user.name} 종소세 진입",
        "#tax-ops"
      )
      user
    end
  end
end