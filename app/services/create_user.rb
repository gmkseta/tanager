class CreateUser < Service::Base
  option :owner
  option :token, optional: true

  def run
    user = ActiveRecord::Base.transaction do
      businesses = owner.businesses.joins(:hometax_business)
      user = User.create!(
        login: owner.login || businesses.first.registration_number,
        password: owner.login || businesses.first.registration_number,
        name: owner.name || businesses.first.owner_name,
        owner_id: owner.id,
        token: token,
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
          hometax_classification_code: b.hometax_business.classification_code,
          taxation_type: b.hometax_business.taxation_type,
          opened_at: b.hometax_business.opened_at,
          official_name: b.hometax_business.official_name,
          official_code: b.hometax_business.official_code,
          official_number: b.hometax_business.official_number
        )
      end
      user
    end
  end
end