class BusinessExpense < ApplicationRecord
  belongs_to :declare_user
  belongs_to :expense_classification, class_name: "Classification", foreign_key: :expense_classification_id
  belongs_to :account_classification, class_name: "Classification", foreign_key: :account_classification_id, optional: true

  validates :expense_classification_id, presence: true, inclusion: { in: Classification.business_expenses.ids, message: :invalid_type }
  validates :account_classification_id, inclusion: { in: Classification.account_classifications.ids, message: :invalid_type }
  validates :amount, presence: true, numericality: { greater_than: 0, message: :greater_than_zero }
end
