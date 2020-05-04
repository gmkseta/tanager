class BusinessExpense < ApplicationRecord
  belongs_to :declare_user
  belongs_to :expense_classification, class_name: "Classification", foreign_key: :expense_classification_id
  belongs_to :account_classification, class_name: "Classification", foreign_key: :account_classification_id, optional: true

  validate :expense_classification_id, :validate_unique_expense?, on: :create
  validates :expense_classification_id, presence: true, inclusion: { in: Classification.business_expenses.ids, message: :invalid_type }
  validates :account_classification_id, inclusion: { in: Classification.account_classifications.ids, message: :invalid_type }, allow_nil: true
  validates :amount, presence: true, numericality: { greater_than: 0, message: :greater_than_zero }

  def validate_unique_expense?
    return false if Classification::EXPENSE_INVOICE_CLASSIFICATION.any?(expense_classification_id)
    if BusinessExpense.where(expense_classification_id: expense_classification_id, declare_user_id: declare_user_id).present?
      errors.add(:expense_classification_id, :taken)
    end
  end
end
