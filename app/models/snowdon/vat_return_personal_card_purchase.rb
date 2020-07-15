class Snowdon::VatReturnPersonalCardPurchase < Snowdon::ApplicationRecord
  belongs_to :vat_return

  validates :card_number, format: { with: /\A\d{12,19}\z/ }, presence: true
  validates :vendor_registration_number, format: { with: /\A\d{10}\z/ }
  with_options numericality: { greater_than_or_equal_to: 0 } do
    validates :price
    validates :vat
    validates :amount
  end

  before_save { self.amount = amount }

  def amount
    price + vat
  end
end
