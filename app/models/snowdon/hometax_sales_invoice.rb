class Snowdon::HometaxSalesInvoice < Snowdon::ApplicationRecord
  REVISED_INVOICE_TYPES = %w(일반(수정) 수입(수정) 위수탁(수정) 영세율(수정) 영세율위수탁(수정)).freeze

  belongs_to :business

  has_one :document, as: :source
  has_one :original_invoice, primary_key: :original_authorization_number, foreign_key: :authorization_number, class_name: "HometaxSalesInvoice"

  validates :tax_invoice, inclusion: { in: [true, false] }
  validates :invoice_type, presence: true
  validates :issue_type, presence: true
  validates :received, inclusion: { in: [true, false] }
  validates :price, presence: true
  validates :tax, presence: true
  validates :amount, presence: true
  validates :customer_registration_number, presence: true
  validates :authorization_number, presence: true, uniqueness: { scope: :business }
  validates :written_at, presence: true
  validates :issued_at, presence: true
  validates :sent_at, presence: true

  scope :recent, -> { order(written_at: :desc) }
  scope :revised, -> { where(invoice_type: REVISED_INVOICE_TYPES) }
  scope :not_revised, -> { where.not(invoice_type: REVISED_INVOICE_TYPES) }
  scope :invalid_tax, -> { where(tax_invoice: true, invoice_type: %w(일반 위수탁), tax: 0).where("ABS(price) >= 10") }

  scope :tax_free, -> { where(tax_invoice: false) }
  scope :taxation, -> { where(tax_invoice: true) }

  def self.registration_number_attr_name
    :customer_registration_number
  end

  def canceled?
    amount.negative?
  end

  def customer_name
    customer_business_name.presence || customer_owner_name
  end
end
