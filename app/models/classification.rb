class Classification < ApplicationRecord
  has_many :simplified_bookkeepings

  scope :relations, ->{ where(classification_type: "Relation") }
  scope :business_expenses, ->{ where(classification_type: "BusinessExpense") }
  scope :account_classifications, ->{ where(classification_type: "AccountClassification") }

  EXPENSE_INVOICE_CLASSIFICATION = [18, 19]

  def self.with_amount(classifications, results)
    classifications.each do |c|
      c["amount"] = results[c["id"]] || 0
    end
    classifications
  end
end
