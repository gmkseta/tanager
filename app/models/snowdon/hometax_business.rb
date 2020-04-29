class Snowdon::HometaxBusiness < Snowdon::ApplicationRecord
  belongs_to :business

  validates :business, uniqueness: true

  validates :address, presence: true

  validates :operation_status, presence: true
  validates :taxation_type, presence: true

  validates :login, presence: true

  validates :official_name, presence: true
  validates :official_code, presence: true
  validates :official_number, presence: true
end
