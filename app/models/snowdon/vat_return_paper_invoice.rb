class Snowdon::VatReturnPaperInvoice < Snowdon::ApplicationRecord
  enum invoice_type: { purchases: "매입", sales: "매출" }

  belongs_to :vat_return

  validates :invoice_type, presence: true
  validates :trader_business_name, presence: true
  validates :trader_registration_number, format: { with: /\A\d{10}\z/ }
  validates :written_at, presence: true

  with_options numericality: { greater_than_or_equal_to: 0 } do
    validates :price
    validates :vat
    validates :amount
  end

  scope :tax_free, -> { where(vat: 0) }
  scope :taxation, -> { where.not(vat: 0) }

  before_save { self.amount = amount }

  def amount
    price + vat
  end

  def tax_invoice?
    vat.positive?
  end
end
