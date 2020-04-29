class Snowdon::HometaxPurchasesCashReceipt < Snowdon::ApplicationRecord
  enum receipt_type: %i(approved canceled)

  belongs_to :business
  belongs_to :hometax_business

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :vat, numericality: { greater_than_or_equal_to: 0 }
  validates :service, numericality: { greater_than_or_equal_to: 0 }
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :tax_deductible, inclusion: { in: [true, false] }
  validates :vendor_registration_number, presence: true
  validates :authorization_number, presence: true, uniqueness: { scope: %i(business purchased_at) }
  validates :receipt_type, presence: true
  validates :purchased_at, presence: true

  scope :recent, -> { order(purchased_at: :desc) }
  scope :last_year, -> {where(purchased_at: 1.year.ago.all_year)}

  def amount
    canceled? ? -self[:amount] : self[:amount]
  end

  def vat
    canceled? ? -self[:vat] : self[:vat]
  end
end
