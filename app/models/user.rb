class User < ApplicationRecord
  has_many :user_providers
  has_many :declare_user

  has_secure_password

  def jwt(sudo: false)
    Knock::AuthToken.new(payload: to_token_payload(sudo: sudo))
  end

  def to_token_payload(sudo: false)
    {
      sub: id,
      login: login,
      name: name,
      sudo: sudo ? 10.minutes.from_now.to_i : nil
    }.compact
  end

  def sudo!(sudo)
    @sudo = sudo
    self
  end

  def sudo?
    @sudo
  end
end
