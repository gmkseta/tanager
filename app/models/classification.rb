class Classification < ApplicationRecord
  scope :relations, ->{ where(classification_type: "Relation") }
  scope :business_expenses, ->{ where(classification_type: "BusinessExpense") }
  scope :account_classifications, ->{ where(classification_type: "AccountClassification") }
end
