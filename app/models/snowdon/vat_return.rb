class Snowdon::VatReturn < Snowdon::ApplicationRecord
  enum status: {
    started: 0,
    form_generated: 1,
    file_requested: 2,
    file_created: 3,
    finished: 4,
  }

  belongs_to :business

  has_one :pre_form, class_name: "GeneralVatReturnPreForm"
  has_one :form, class_name: "GeneralVatReturnForm"
  has_many :extra_sales_recaps, class_name: "VatReturnExtraSalesRecap"
  has_many :personal_card_purchases, class_name: "VatReturnPersonalCardPurchase"
  has_many :paper_invoices, class_name: "VatReturnPaperInvoice"
  has_many :deductible_purchases, class_name: "VatReturnDeductiblePurchase"
  has_many :deemed_purchases, class_name: "VatReturnDeemedPurchase"

  validates :year, presence: true
  validates :period, uniqueness: { scope: %i(business year) }, inclusion: { in: [1, 2] }
  validates :status, presence: true
  validates :started_at, presence: true
  validates :form_generated_at, presence: true, if: :form_generated?
  validates :file_requested_at, presence: true, if: :file_requested?
  validates :electronic_file, presence: true, if: :file_created?
  validates :file_created_at, presence: true, if: :file_created?
  validates :finished_at, presence: true, if: :finished?
  validates :return_response, presence: true, if: :finished?

  def member_cd
    "M#{business.id}"
  end

  def term_cd
   "#{year}#{period}"
  end
end