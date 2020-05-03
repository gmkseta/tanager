class BusinessExpense < ApplicationRecord
  belongs_to :declare_user
  belongs_to :expense_classification, class_name: "Classification", foreign_key: :expense_classification_id
  belongs_to :account_classification, class_name: "Classification", foreign_key: :account_classification_id, optional: true

  validates :expense_classification_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0, message: :greater_than_zero }
end
