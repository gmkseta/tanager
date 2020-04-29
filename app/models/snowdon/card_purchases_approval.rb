class Snowdon::CardPurchasesApproval < Snowdon::ApplicationRecord
  enum currency: %i(krw usd)

  belongs_to :business
  belongs_to :hometax_business

  validates :status, presence: true
  validates :authorization_number, uniqueness: { scope: %i(business status amount) }
  validates :issuer_name, presence: true
  validates :installment, presence: true
  validates :currency, presence: true
  validates :approved_at, presence: true

  scope :approved, -> { where(status: "승인").where(ar[:amount].gt(0)) }
  scope :canceled, -> { where.not(status: "승인").or(where(ar[:amount].lt(0))) }
  scope :recent, -> { order(approved_at: :desc) }
  scope :domestic, -> { where.not(amount: nil).krw }
  scope :last_year, -> {where(approved_at: 1.year.ago.all_year)}

  def approved?
    self[:status] == "승인" && self[:amount].positive?
  end

  def status
    approved? ? "승인" : "취소"
  end

  def amount
    (self[:amount].negative? || approved?) ? self[:amount] : 0
  end

  def raw_amount
    self[:amount]
  end

  def lumpsum?
    installment < 2
  end
end
