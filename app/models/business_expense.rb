class BusinessExpense < ApplicationRecord
  belongs_to :declare_user
  belongs_to :expense_classification, class_name: "Classification", foreign_key: :expense_classification_id
  belongs_to :account_classification, class_name: "Classification", foreign_key: :account_classification_id, optional: true

  validate :expense_classification_id, :validate_unique_expense?, on: :create
  validates :expense_classification_id, presence: true, inclusion: { in: Classification.business_expenses.ids, message: :invalid_type }
  validates :account_classification_id, inclusion: { in: Classification.account_classifications.ids, message: :invalid_type }, allow_nil: true
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 0, message: :greater_than_or_equal_to_zero }
  validates :vendor_registration_number, format: { with: /\A\d{10}\z/ }, allow_nil: true
  validate :last_year_issued_at?

  def validate_unique_expense?
    return false if Classification::EXPENSE_INVOICE_CLASSIFICATION.any?(expense_classification_id)
    if BusinessExpense.where(expense_classification_id: expense_classification_id, declare_user_id: declare_user_id).present?
      errors.add(:expense_classification_id, :taken)
    end
  end

  def last_year_issued_at?
    return true unless Classification::EXPENSE_INVOICE_CLASSIFICATION.any?(expense_classification_id)
    if issued_at.blank?
      errors.add(:issued_at, :invalid)
    elsif !1.year.ago.all_year.include?(issued_at)
      errors.add(:issued_at, :invalid)
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
end
