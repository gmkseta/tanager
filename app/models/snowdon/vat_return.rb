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

  def grouped_hometax_card_purchases(date_range)
    @grouped_hometax_card_purchases ||= begin
      business.hometax_card_purchases
        .where(purchased_at: date_range)
        .group(:vendor_registration_number)
        .select(Arel.sql(<<~QUERY))
          vendor_registration_number,
          MAX(vendor_business_name),
          SUM(amount)
          SUM(vat),
          SUM(price),
          COUNT(*),
          MIN(deductible::integer)::boolean as deducible
        QUERY
    end
  end

  def grouped_hometax_sales_invoices(date_range)
    @grouped_hometax_sales_invoices ||= begin
      business.hometax_sales_invoices
        .where(written_at: date_range)
        .group(:customer_registration_number)
        .pluck(Arel.sql(<<~QUERY))
          customer_registration_number,
          MAX(customer_business_name) as business_name,
          MAX(written_at),
          SUM(amount),
          SUM(tax),
          SUM(price),
          COUNT(*),
          FALSE as paper_invoice
        QUERY
    end
  end

  def grouped_hometax_purchases_invoices(date_range)
    @grouped_hometax_purchases_invoices ||= begin
      business.hometax_purchases_invoices
        .where(written_at: date_range)
        .group(:vendor_registration_number)
        .pluck(Arel.sql(<<~QUERY))
          vendor_registration_number,
          MAX(vendor_business_name) as business_name,
          MAX(written_at),
          SUM(amount),
          SUM(tax),
          SUM(price),
          COUNT(*),
          TRUE as deducible,
          FALSE as paper
        QUERY
    end
  end

  def grouped_paper_invoices(is_sales: nil, is_tax_free: nil)
    @grouped_paper_invoices ||= begin
      invoices = paper_invoices.group(:trader_registration_number)
      invoices = is_sales ? invoices.sales : invoices.purchases if is_sales.present?
      invoices = is_tax_free ? invoices.tax_free : invoices.taxation if is_tax_free.present?
      invoices.pluck(Arel.sql(<<~QUERY))
        trader_registration_number,
        MAX(trader_business_name) as business_name,
        MAX(written_at),
        SUM(amount),
        SUM(vat),
        SUM(price),
        COUNT(*),
        TRUE as deducible,
        TRUE as paper
      QUERY
    end
  end
end