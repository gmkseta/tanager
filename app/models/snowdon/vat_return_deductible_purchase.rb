class Snowdon::VatReturnDeductiblePurchase < Snowdon::ApplicationRecord
  belongs_to :vat_return
  belongs_to :nodeduct_reason, optional: true

  validates :purchase_type, inclusion: { in: %w(HometaxCardPurchase HometaxPurchasesCashReceipt HometaxPurchasesInvoice) }
  validates :vendor_registration_number, format: { with: /\A\d{10}\z/ }, uniqueness: { scope: %i(vat_return purchase_type vendor_registration_number) }
  validates :deductible, inclusion: { in: [true, false] }

  validate :non_deductible_invoice_should_have_reason

  scope :purchases_invoices, -> { where(purchase_type: "HometaxPurchasesInvoice") }
  scope :no_deductions, -> { where.not(nodeduct_reason_id: nil) }

  private

  def non_deductible_invoice_should_have_reason
    errors.add(:nodeduct_reason, :required) if purchase_type == "HometaxPurchasesInvoice" && !deductible && nodeduct_reason.nil?
  end
end
