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

  def exclude_covid19_deduction?
    pre_form&.covid19_deduction_excluded == true
  end

  def grouped_hometax_card_purchases(date_range = form.date_range)
    codes, _, _ = deemed_purchasable_info

    @grouped_hometax_card_purchases ||= begin
      business.hometax_card_purchases
        .where(purchased_at: date_range)
        .group(:vendor_registration_number)
        .pluck(Arel.sql(<<~QUERY))
          vendor_registration_number,
          MAX(vendor_business_name) as vendor_business_name,
          MAX(card_number),
          MAX(purchased_at) as purchased_at,
          SUM(amount),
          SUM(vat),
          SUM(price),
          COUNT(*),
          MIN(deductible::integer)::boolean as deducible,
          MAX(vendor_business_classification_code) ~* '(#{codes})' as deemed,
          'HometaxCardPurchase' as type
        QUERY
    end
  end

  def grouped_purchases_cash_receipts(date_range = form.date_range)
    codes, _, _ = deemed_purchasable_info

    @grouped_purchases_cash_receipts ||= begin
      business.hometax_purchases_cash_receipts
        .where(purchased_at: date_range)
        .group(:vendor_registration_number)
        .pluck(Arel.sql("
          vendor_registration_number,
          MAX(vendor_business_name),
          '' as card_number,
          MAX(purchased_at),
          SUM(CASE WHEN receipt_type = 0 THEN amount ELSE -amount END),
          SUM(CASE WHEN receipt_type = 0 THEN vat ELSE -vat END),
          SUM(CASE WHEN receipt_type = 0 THEN price ELSE -price END),
          COUNT(*),
          MIN(tax_deductible::integer)::boolean,
          MAX(vendor_business_code) ~* '(#{codes})' as deemed,
          'HometaxPurchasesCashReceipt' as type
        "))
    end
  end

  def grouped_personal_cards
    @grouped_personal_cards ||= begin
      personal_card_purchases.group(:vendor_registration_number, :card_number)
        .pluck(Arel.sql(<<~QUERY))
          vendor_registration_number,
          '',
          card_number,
          '' as purchased_at,
          SUM(amount),
          SUM(vat),
          SUM(price),
          COUNT(*),
          TRUE as deductible,
          TRUE as deemed,
          'VatReturnPersonalCardPurchase' as type
        QUERY
    end
  end

  def grouped_hometax_purchases_invoices(date_range = form.date_range)
    _, classifications, categories = deemed_purchasable_info

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
          MAX(vendor_business_classification) ~* '(#{classifications})' OR MAX(vendor_business_category) ~* '(#{categories})' as deemed,
          'HometaxPurchasesInvoice' as type
        QUERY
    end
  end

  def grouped_hometax_sales_invoices(date_range = form.date_range)
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
          TRUE as deducible,
          TRUE as deemed,
          'HometaxSalesInvoice' as type
        QUERY
    end
  end

  def grouped_sales_paper_invoices
    @grouped_sales_paper_invoices ||= begin
      paper_invoices.sales.group(:trader_registration_number)
        .pluck(Arel.sql(<<~QUERY))
          trader_registration_number,
          MAX(trader_business_name) as business_name,
          MAX(written_at),
          SUM(amount),
          SUM(vat),
          SUM(price),
          COUNT(*),
          TRUE as deducible,
          TRUE as deemed,
          'VatReturnPaperInvoice' as type
        QUERY
    end
  end

  def grouped_purchases_paper_invoices
    @grouped_purchases_paper_invoices ||= begin
      paper_invoices.purchases.group(:trader_registration_number)
        .pluck(Arel.sql(<<~QUERY))
          trader_registration_number,
          MAX(trader_business_name) as business_name,
          MAX(written_at),
          SUM(amount),
          SUM(vat),
          SUM(price),
          COUNT(*),
          TRUE as deducible,
          TRUE as deemed,
          'VatReturnPaperInvoice' as type
        QUERY
    end
  end

  def deemed_purchasable_info
    @deemed_purchasable_info ||= begin
      codes = Snowdon::HometaxBusinessClassification.deemed_purchasable_codes.join("|")
      classifications = Snowdon::HometaxPurchasesInvoice::DEEMED_PURCHASABLE_CLASSIFICATIONS.join("|")
      categories = Snowdon::HometaxPurchasesInvoice::DEEMED_PURCHASABLE_CATEGORIES.join("|")

      [codes, classifications, categories]  
    end
  end

  def deemed_purchases_deductibles
    @deemed_purchases_deductibles ||= begin
      deemed_purchases.group_by do |purchase|
        [purchase.vendor_registration_number, purchase.purchase_type]
      end
    end
  end

  def grouped_deductible_purchases
    @grouped_deductible_purchases ||= begin
      deductible_purchases.group_by do |purchase|
        [purchase.vendor_registration_number, purchase.purchase_type]
      end
    end
  end
end