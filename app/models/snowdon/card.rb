class Snowdon::Card < Snowdon::ApplicationRecord
  belongs_to :business

  validates :issuer, presence: true
  validates :number, format: { with: /\A\d{12,19}\z/ }, uniqueness: { scope: %i(business issuer) }
end
