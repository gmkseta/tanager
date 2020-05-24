class BusinessExpense < ApplicationRecord
  self.per_page = 10000
  belongs_to :declare_user
  belongs_to :expense_classification, class_name: "Classification", foreign_key: :expense_classification_id
  belongs_to :account_classification, class_name: "Classification", foreign_key: :account_classification_id, optional: true

  scope :paper_invoices_receipts, ->{ where(expense_classification_id: [18, 19]) }
  scope :paper_and_personal_cards, ->{ where(expense_classification_id: [18, 19, 53]) }

  validate :expense_classification_id, :validate_unique_expense?, on: :create
  validates :expense_classification_id, presence: true, inclusion: { in: Classification.business_expenses.ids + Classification.personal_cards.ids, message: :invalid_type }
  validates :account_classification_id, inclusion: { in: Classification.account_classifications.ids, message: :invalid_type }, allow_nil: true
  validates :amount, length: { maximum: 15, message: :maximum_length }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, message: :greater_than_or_equal_to_zero }
  validates :vendor_registration_number, format: { with: /\A\d{10}\z/ }, allow_nil: true
  validates :issued_at, inclusion: { in: 1.year.ago.all_year, message: :wrong_date }, allow_nil: true

  PERSONAL_CARD_CLASSIFICATION_ID = 53
  LOCAL_INSURANCE_CLASSIFICATION_ID = 20
  BUSINESS_INSURANCE_CLASSIFICATION_ID = 17
  WAGE_CLASSIFICATION_ID = 14

  def validate_unique_expense?
    return false if Classification::EXPENSE_INVOICE_CLASSIFICATION.any?(expense_classification_id)
    if BusinessExpense.where(expense_classification_id: expense_classification_id, declare_user_id: declare_user_id).present?
      errors.add(:expense_classification_id, :taken)
    end
  end

  def expense_classification_name
    expense_classification&.name
  end

  def account_classification_name
    account_classification&.name
  end

  def self.personal_cards_sum(declare_user_id)
    BusinessExpense.where(
      declare_user_id: declare_user_id,
      expense_classification_id: Classification::PERSONAL_CARD_CLASSIFICATION_ID
    ).sum(:amount)
  end

  def self.create_insurances(declare_user_id, registration_number)
    local_insurances_sum = DeclareUser.find(declare_user_id).hometax_social_insurances.local_insurances_sum
    BusinessExpense.create(
      declare_user_id: declare_user_id,
      expense_classification_id: Classification::LOCAL_INSURANCE_CLASSIFICATION_ID,
      amount: local_insurances_sum,
    )
    businesses_insurances_sum = DeclareUser.find(declare_user_id)
      .hometax_social_insurances
      .where(hometax_social_insurances: { registration_number: registration_number })
      .businesses_insurances_sum
    BusinessExpense.create(
      declare_user_id: declare_user_id,
      expense_classification_id: Classification::BUSINESS_INSURANCE_CLASSIFICATION_ID,
      amount: businesses_insurances_sum,
    )
  end

  def self.create_wage(declare_user_id)
    BusinessExpense.create(
      declare_user_id: declare_user_id,
      expense_classification_id: Classification::WAGE_CLASSIFICATION_ID,
      amount: DeclareUser.find(declare_user_id).wage_sum,
    )
  end
end
