class CreateUser < Service::Base
  option :businesses
  option :token
  option :provider, optional: true

  def run    
    public_id = businesses.first["id"]
    business = Snowdon::Business.find_by(public_id: public_id)
    hometax_business = Snowdon::HometaxBusiness.find_by(business_id: business.id)
    user = ActiveRecord::Base.transaction do
      user = User.create!(
        login: business.registration_number,
        password: business.registration_number,
        name: hometax_business.name,
        hometax_account: hometax_business.login,
        phone_number: hometax_business.phone_number
      )
      UserProvider.create!(
        user_id: user.id,
        provider: provider || "cashnote",
        uid: public_id,
        response: businesses,
        token: token
      )
      user
    end
    user
  end
end
