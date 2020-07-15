class Snowdon::VatReturnDeemedPurchase < Snowdon::ApplicationRecord
  enum purchase_type: {
    business_cards: "사업용카드",
    personal_cards: "개인카드",
    cash_receipts: "현금영수증",
    invoices: "세금계산서",
    paper_invoices: "종이계산서",
  }

  belongs_to :vat_return

  validates :purchase_type, presence: true
  validates :vendor_registration_number, format: { with: /\A\d{10}\z/ }, uniqueness: { scope: %i(vat_return purchase_type vendor_registration_number) }
  validates :deemed, inclusion: { in: [true, false] }
end
