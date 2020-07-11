class Snowdon::HometaxPurchasesInvoice < Snowdon::ApplicationRecord
  TAX_FREE_VENDOR_CLASSIFICATIONS = %w(농업 임업 수산 축산 김치 두부 소금 도매 소매 제조 도소매 식품 가공 곡물 과일 야채 농산 식자 유통 육류 음식 유제 유가공).freeze
  TAX_FREE_VENDOR_CATEGORIES = %w(쌀 수산 참치 식품 생선).freeze
  REVISED_INVOICE_TYPES = %w(일반(수정) 수입(수정) 위수탁(수정) 영세율(수정) 영세율위수탁(수정)).freeze

  belongs_to :business
  belongs_to :hometax_business

  validates :tax_invoice, inclusion: { in: [true, false] }
  validates :invoice_type, presence: true
  validates :issue_type, presence: true
  validates :paid, inclusion: { in: [true, false] }
  validates :price, presence: true
  validates :tax, presence: true
  validates :amount, presence: true
  validates :vendor_registration_number, presence: true
  validates :authorization_number, presence: true, uniqueness: { scope: :business }
  validates :written_at, presence: true
  validates :issued_at, presence: true
  validates :sent_at, presence: true

  scope :recent, -> { order(written_at: :desc) }
  scope :electricity, -> { where(ar[:item_name].matches_regexp("전기료|전기요금|전력기금|전기사용료")) }
  scope :revised, -> { where(invoice_type: REVISED_INVOICE_TYPES) }
  scope :not_revised, -> { where.not(invoice_type: REVISED_INVOICE_TYPES) }
  scope :invalid_tax, -> { where(tax_invoice: true, invoice_type: %w(일반 위수탁), tax: 0).where("ABS(price) >= 10") }
  scope :last_year, -> {where(written_at: 1.year.ago.all_year)}

  scope :tax_free, -> { where(tax_invoice: false) }
  scope :taxation, -> { where(tax_invoice: true) }

  class << self
    def communications
      where(<<-SQL.squish)
        (vendor_registration_number = '1028142945' and (item_name ~* '(통화|전화|LTE)' OR note LIKE '%전화%'))
        OR (vendor_registration_number = '1048137225' and item_name like '%통신요금%')
        OR (vendor_registration_number = '2208139938' and item_name like '%서비스%')
        OR (vendor_registration_number = '1178113423' and item_name like '%MVNO%')
        OR (vendor_registration_number = '1048143391' and item_name ~* '(MVNO|통신서비스)')
        OR (vendor_registration_number = '2148618758' and item_name like '%통신요금%')
      SQL
    end

    def from_tax_free_vendors
      classifications = TAX_FREE_VENDOR_CLASSIFICATIONS.map { |str| "'%#{str}%'" }.join(",")
      categories = TAX_FREE_VENDOR_CATEGORIES.map { |str| "'%#{str}%'" }.join(",")

      where(tax_invoice: false, tax: 0).where(<<-SQL.squish)
        vendor_business_classification LIKE any (array[#{classifications}])
        OR vendor_business_category LIKE any (array[#{categories}])
      SQL
    end

    def registration_number_attr_name
      :vendor_registration_number
    end
  end

  def canceled?
    amount.negative?
  end
end
